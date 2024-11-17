import XCTest
import AVFoundation
@testable import WhisperTranscriptionApp

class WhisperModelManagerTests: XCTestCase {
    var modelManager: WhisperModelManager!

    override func setUp() {
        super.setUp()
        modelManager = WhisperModelManager.shared
        try? modelManager.loadModel()
    }

    override func tearDown() {
        modelManager = nil
        super.tearDown()
    }

    func testModelLoading() {
        XCTAssertNotNil(modelManager.model, "Model should not be nil after loading")
    }

    func testTranscriptionWithValidAudio() {
        guard let bundle = Bundle(for: type(of: self)),
              let audioURL = bundle.url(forResource: "test_sample", withExtension: "wav") else {
            XCTFail("Test audio file 'test_sample.wav' not found in test bundle")
            return
        }
        
        let file: AVAudioFile
        do {
            file = try AVAudioFile(forReading: audioURL)
        } catch {
            XCTFail("Error reading audio file: \(error)")
            return
        }
        
        guard let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 16000.0, channels: 1, interleaved: false) else {
            XCTFail("Failed to create audio format")
            return
        }
        
        let frameCount = AVAudioFrameCount(file.length)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            XCTFail("Failed to create PCM buffer")
            return
        }
        
        do {
            try file.read(into: buffer)
            let expectation = self.expectation(description: "Transcription completes")
            modelManager.transcribe(audioBuffer: buffer.floatChannelData![0], bufferSize: Int(buffer.frameLength)) { result in
                switch result {
                case .success(let transcription):
                    XCTAssertFalse(transcription.isEmpty, "Transcription should not be empty")
                    XCTAssertEqual(transcription.lowercased(), "this is a test sample", "Transcription should match expected text")
                case .failure(let error):
                    XCTFail("Transcription failed with error: \(error)")
                }
                expectation.fulfill()
            }
            waitForExpectations(timeout: 10, handler: nil)
        } catch {
            XCTFail("Error reading audio buffer: \(error)")
        }
    }

    func testTranscriptionWithInvalidAudio() {
        guard let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 16000.0, channels: 1, interleaved: false),
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 1024) else {
            XCTFail("Failed to create audio format or buffer")
            return
        }
        buffer.frameLength = 1024
        
        let expectation = self.expectation(description: "Transcription completes")
        modelManager.transcribe(audioBuffer: buffer.floatChannelData![0], bufferSize: Int(buffer.frameLength)) { result in
            switch result {
            case .success(_):
                XCTFail("Transcription should fail with invalid audio data")
            case .failure(let error):
                XCTAssertNotNil(error, "Error should not be nil")
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
} 