import XCTest

class TranscriptionFlowTests: XCTestCase {
    func testRecordingAndTranscriptionFlow() {
        let app = XCUIApplication()
        app.launch()
        
        let recordButton = app.buttons["StartRecordingButton"]
        XCTAssertTrue(recordButton.waitForExistence(timeout: 5))
        recordButton.tap()
        
        // Simulate waiting for recording
        sleep(5)
        
        let stopButton = app.buttons["StopRecordingButton"]
        XCTAssertTrue(stopButton.exists)
        stopButton.tap()
        
        let transcriptionTextView = app.textViews["TranscriptionTextView"]
        XCTAssertTrue(transcriptionTextView.waitForExistence(timeout: 10))
        XCTAssertFalse(transcriptionTextView.value as? String == "")
    }
} 