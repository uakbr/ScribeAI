import XCTest

class ScreenshotGenerator: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        setupSnapshot(app)
        app = XCUIApplication()
        app.launchArguments += ["--uitesting"]
    }
    
    func testGenerateScreenshots() throws {
        app.launch()
        
        // Home screen
        snapshot("01_Home")
        
        // Recording screen
        app.buttons["Start Recording"].tap()
        snapshot("02_Recording")
        
        // Transcription list
        app.buttons["Stop Recording"].tap()
        snapshot("03_TranscriptionList")
        
        // Settings screen
        app.buttons["Settings"].tap()
        snapshot("04_Settings")
    }
    
    private func snapshot(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
} 