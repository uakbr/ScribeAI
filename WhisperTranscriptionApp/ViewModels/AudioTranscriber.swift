import Foundation
import AVFoundation

class AudioTranscriber {
    static let shared = AudioTranscriber()
    private let transcriptionQueue = DispatchQueue(label: "com.app.transcription", qos: .userInitiated)
    private var transcriptionBuffer: [AVAudioPCMBuffer] = []
    private let bufferLock = NSLock()
    private let maxBufferLength = 16000 * 30  // 30 seconds at 16kHz

    func startTranscribing() {
        // Start or resume transcribing
        processTranscriptionBuffer()
    }

    func pauseTranscribing() {
        // Pause transcribing
    }

    func resumeTranscribing() throws {
        // Resume transcribing
        processTranscriptionBuffer()
    }

    func appendAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        transcriptionQueue.async { [weak self] in
            guard let self = self else { return }
            self.bufferLock.lock()
            self.transcriptionBuffer.append(buffer)
            if self.transcriptionBuffer.count > self.maxBufferLength {
                self.transcriptionBuffer.removeFirst(self.transcriptionBuffer.count - self.maxBufferLength)
            }
            self.bufferLock.unlock()
        }
    }

    private func processTranscriptionBuffer() {
        transcriptionQueue.async { [weak self] in
            guard let self = self else { return }
            self.bufferLock.lock()
            let bufferCopy = self.transcriptionBuffer
            self.transcriptionBuffer.removeAll()
            self.bufferLock.unlock()

            for buffer in bufferCopy {
                self.processAudioBuffer(buffer)
            }
        }
    }

    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        WhisperModelManager.shared.transcribe(audioBuffer: buffer) { result in
            switch result {
            case .success(let transcription):
                // Handle successful transcription
                print("Transcription: \(transcription)")
            case .failure(let error):
                // Handle error
                print("Transcription error: \(error.localizedDescription)")
            }
        }
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}