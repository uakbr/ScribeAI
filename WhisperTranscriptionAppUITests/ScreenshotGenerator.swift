import XCTest

class ScreenshotGenerator: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        setupSnapshot(app)
        app.launchArguments += ["--uitesting"]
        app.launch()
    }
    
    func testGenerateScreenshots() {
        // Home screen
        snapshot("01_HomeScreen")
        
        // Start Recording
        let recordButton = app.buttons["StartRecordingButton"]
        XCTAssertTrue(recordButton.waitForExistence(timeout: 5))
        recordButton.tap()
        sleep(5) // Simulate recording time
        snapshot("02_Recording")
        
        // Stop Recording
        let stopButton = app.buttons["StopRecordingButton"]
        XCTAssertTrue(stopButton.waitForExistence(timeout: 5))
        stopButton.tap()
        snapshot("03_TranscriptionView")
        
        // Transcription List
        app.tabBars.buttons["Transcriptions"].tap()
        snapshot("04_TranscriptionList")
        
        // Settings screen
        app.tabBars.buttons["Settings"].tap()
        snapshot("05_Settings")
    }
    
    private func snapshot(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
} 