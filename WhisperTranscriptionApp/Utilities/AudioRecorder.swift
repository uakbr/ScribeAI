class AudioRecorder {
    private var audioEngine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?
    
    func startRecording() throws {
        audioEngine = AVAudioEngine()
        inputNode = audioEngine?.inputNode
        
        let recordingFormat = inputNode?.outputFormat(forBus: 0)
        inputNode?.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, time in
            self?.processAudioBuffer(buffer)
        }
        
        try audioEngine?.start()
    }
    
    deinit {
        audioEngine?.stop()
        inputNode?.removeTap(onBus: 0)
    }
} 