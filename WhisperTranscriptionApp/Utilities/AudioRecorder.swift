import AVFoundation
import UIKit

class AudioRecorder {
    private var audioEngine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?
    private var isRecording = false

    func startRecording() throws {
        // Request microphone permission if not already granted
        let status = AVAudioSession.sharedInstance().recordPermission
        switch status {
        case .undetermined:
            await requestMicrophonePermission()
        case .denied:
            print("Microphone access denied")
            return
        case .granted:
            break
        @unknown default:
            break
        }

        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else {
            throw AudioRecorderError.engineInitializationFailed
        }

        inputNode = audioEngine.inputNode
        let recordingFormat = inputNode!.outputFormat(forBus: 0)
        inputNode!.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.processAudioBuffer(buffer)
        }

        do {
            try audioEngine.start()
            isRecording = true
        } catch {
            throw AudioRecorderError.audioEngineStartFailed(error)
        }
    }

    func stopRecording() {
        audioEngine?.stop()
        inputNode?.removeTap(onBus: 0)
        audioEngine = nil
        inputNode = nil
        isRecording = false
    }

    private func requestMicrophonePermission() async {
        await AVAudioSession.sharedInstance().requestRecordPermission()
    }

    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        // Process the audio buffer using AudioProcessor
        do {
            let processedBuffer = try AudioProcessor.shared.processAudioBuffer(buffer)
            // Pass the processed buffer to the transcriber
            AudioTranscriber.shared.appendAudioBuffer(processedBuffer)
        } catch {
            print("Audio processing error: \(error.localizedDescription)")
        }
    }

    deinit {
        stopRecording()
    }
}

enum AudioRecorderError: LocalizedError {
    case engineInitializationFailed
    case inputNodeUnavailable
    case audioEngineStartFailed(Error)

    var errorDescription: String? {
        switch self {
        case .engineInitializationFailed:
            return "Failed to initialize audio engine."
        case .inputNodeUnavailable:
            return "Audio input node is unavailable."
        case .audioEngineStartFailed(let error):
            return "Failed to start audio engine: \(error.localizedDescription)"
        }
    }
} 