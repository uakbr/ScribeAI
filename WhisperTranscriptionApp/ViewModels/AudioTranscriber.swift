import Foundation
import AVFoundation
import Accelerate

class AudioTranscriber: NSObject {
    // MARK: - Properties
    static let shared = AudioTranscriber()
    
    private let whisperManager = WhisperModelManager.shared
    private let tokenizer = WhisperTokenizer.shared
    private var audioEngine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?
    private var audioConverter: AVAudioConverter?
    
    private var transcriptionBuffer = [Float]()
    private let transcriptionLock = NSLock()
    private var isTranscribing = false
    private let modelSampleRate: Double = 16000.0
    private let processingInterval: TimeInterval = 5.0
    private let maxAudioLength: TimeInterval = 30.0
    
    private var transcriptionUpdateHandler: ((String) -> Void)?
    private var errorHandler: ((Error) -> Void)?
    private var currentTranscription = ""
    
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    
    // MARK: - Initialization
    private override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption(_:)), name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    // MARK: - Transcription Controls
    func startTranscribing(updateHandler: @escaping (String) -> Void, errorHandler: @escaping (Error) -> Void) throws {
        transcriptionLock.lock()
        defer { transcriptionLock.unlock() }
        
        guard !isTranscribing else { return }
        isTranscribing = true
        self.transcriptionUpdateHandler = updateHandler
        self.errorHandler = errorHandler
        
        // Request microphone permission
        let audioSession = AVAudioSession.sharedInstance()
        switch audioSession.recordPermission {
        case .undetermined:
            audioSession.requestRecordPermission { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        try? self?.startTranscribing(updateHandler: updateHandler, errorHandler: errorHandler)
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.errorHandler?(TranscriptionError.microphonePermissionDenied)
                    }
                }
            }
            return
        case .denied:
            throw TranscriptionError.microphonePermissionDenied
        case .granted:
            break
        @unknown default:
            break
        }
        
        // Setup audio session
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: [])
            try audioSession.setActive(true)
        } catch {
            throw TranscriptionError.audioSessionSetupFailed(error)
        }
        
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else { return }
        
        inputNode = audioEngine.inputNode
        guard let inputNode = inputNode else { return }
        
        let inputFormat = inputNode.outputFormat(forBus: 0)
        guard let converterFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: modelSampleRate, channels: inputFormat.channelCount, interleaved: false) else {
            throw TranscriptionError.audioConverterInitFailed
        }
        
        audioConverter = AVAudioConverter(from: inputFormat, to: converterFormat)
        guard let audioConverter = audioConverter else {
            throw TranscriptionError.audioConverterNotInitialized
        }
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputFormat) { [weak self] (buffer, _) in
            guard let strongSelf = self else { return }
            let pcmBuffer = AVAudioPCMBuffer(pcmFormat: converterFormat, frameCapacity: 1024)!
            var error: NSError?
            let inputBlock: AVAudioConverterInputBlock = { _, outStatus in
                outStatus.pointee = .haveData
                return buffer
            }
            audioConverter.convert(to: pcmBuffer, error: &error, withInputFrom: inputBlock)
            if let error = error {
                strongSelf.errorHandler?(TranscriptionError.audioConversionFailed(error))
                return
            }
            
            strongSelf.transcriptionLock.lock()
            let channelDataArray = Array(UnsafeBufferPointer(start: pcmBuffer.floatChannelData?[0], count: Int(pcmBuffer.frameLength)))
            strongSelf.transcriptionBuffer.append(contentsOf: channelDataArray)
            strongSelf.transcriptionLock.unlock()
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        startBackgroundTask()
        startProcessingTimer()
    }
    
    func stopTranscribing() {
        transcriptionLock.lock()
        defer { transcriptionLock.unlock() }
        
        guard isTranscribing else { return }
        isTranscribing = false
        
        audioEngine?.stop()
        inputNode?.removeTap(onBus: 0)
        audioEngine = nil
        inputNode = nil
        audioConverter = nil
        
        endBackgroundTask()
    }
    
    // MARK: - Processing
    private func startProcessingTimer() {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + processingInterval) { [weak self] in
            self?.processTranscriptionBuffer()
            if self?.isTranscribing == true {
                self?.startProcessingTimer()
            }
        }
    }
    
    private func processTranscriptionBuffer() {
        transcriptionLock.lock()
        let bufferCopy = transcriptionBuffer
        transcriptionBuffer.removeAll()
        transcriptionLock.unlock()
        
        guard !bufferCopy.isEmpty else { return }
        
        whisperManager.transcribe(audioBuffer: bufferCopy, bufferSize: bufferCopy.count) { [weak self] result in
            switch result {
            case .success(let text):
                self?.currentTranscription += text + " "
                DispatchQueue.main.async {
                    self?.transcriptionUpdateHandler?(self?.currentTranscription ?? "")
                }
            case .failure(let error):
                self?.errorHandler?(TranscriptionError.transcriptionFailed(error))
            }
        }
    }
    
    // MARK: - Background Task Management
    private func startBackgroundTask() {
        backgroundTaskID = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.stopTranscribing()
            self?.endBackgroundTask()
        }
    }
    
    private func endBackgroundTask() {
        if backgroundTaskID != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
        }
    }
    
    // MARK: - Interruption Handling
    @objc private func handleInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }
        
        switch type {
        case .began:
            stopTranscribing()
        case .ended:
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    try? startTranscribing(
                        updateHandler: transcriptionUpdateHandler ?? { _ in },
                        errorHandler: errorHandler ?? { _ in }
                    )
                }
            }
        @unknown default:
            break
        }
    }
    
    // MARK: - Public Methods
    func clearTranscription() {
        transcriptionLock.lock()
        defer { transcriptionLock.unlock() }
        
        transcriptionBuffer.removeAll()
        currentTranscription = ""
        DispatchQueue.main.async { [weak self] in
            self?.transcriptionUpdateHandler?("")
        }
    }
    
    var isActive: Bool {
        transcriptionLock.lock()
        defer { transcriptionLock.unlock() }
        return isTranscribing
    }
}

// MARK: - Errors
enum TranscriptionError: Error {
    case audioSessionSetupFailed(Error)
    case audioConverterInitFailed
    case audioConverterNotInitialized
    case bufferCreationFailed
    case audioConversionFailed(Error)
    case invalidAudioData
    case transcriptionFailed(Error)
    case backgroundTaskExpired
    case microphonePermissionDenied
}