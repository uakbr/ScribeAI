import XCTest

class RecordingViewControllerUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("--uitesting")
        app.launch()
    }

    func testRecordingFlow() {
        // Navigate to RecordingViewController
        let transcriptionsNavigationBar = app.navigationBars["Transcriptions"]
        let addButton = transcriptionsNavigationBar.buttons["Add"]
        XCTAssertTrue(addButton.exists, "Add button should exist on Transcriptions screen")
        addButton.tap()

        // Verify that the Start Recording button exists
        let startRecordingButton = app.buttons["Start Recording"]
        XCTAssertTrue(startRecordingButton.exists, "Start Recording button should exist")
        
        // Tap Start Recording and check UI updates
        startRecordingButton.tap()
        
        // Verify that Pause and Stop buttons are visible
        let pauseButton = app.buttons["Pause Recording"]
        let stopButton = app.buttons["Stop Recording"]
        XCTAssertTrue(pauseButton.waitForExistence(timeout: 5), "Pause button should appear after starting recording")
        XCTAssertTrue(stopButton.exists, "Stop button should exist after starting recording")

        // Verify that the transcription label updates
        let transcriptionLabel = app.staticTexts["Transcription will appear here..."]
        XCTAssertTrue(transcriptionLabel.exists, "Transcription label should exist")
        
        // Wait for the transcription label to change
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: "label != %@", "Transcription will appear here..."), object: transcriptionLabel)
        let result = XCTWaiter().wait(for: [expectation], timeout: 10)
        XCTAssertEqual(result, .completed, "Transcription label should update with text")

        // Tap Stop Recording
        stopButton.tap()

        // Verify that recording stops and UI resets
        XCTAssertTrue(startRecordingButton.exists, "Start Recording button should reappear after stopping")
        XCTAssertFalse(pauseButton.exists, "Pause button should disappear after stopping")
        XCTAssertFalse(stopButton.exists, "Stop button should disappear after stopping")
    }

    func testTranscriptionListView() {
        // Ensure at least one transcription exists
        testRecordingFlow()

        // Verify that Transcriptions list is displayed
        let transcriptionsNavigationBar = app.navigationBars["Transcriptions"]
        XCTAssertTrue(transcriptionsNavigationBar.exists, "Transcriptions navigation bar should exist")

        let transcriptionCell = app.tables.cells.element(boundBy: 0)
        XCTAssertTrue(transcriptionCell.waitForExistence(timeout: 5), "There should be at least one transcription cell")

        // Swipe left to reveal Edit and Delete actions
        transcriptionCell.swipeLeft()
        let editButton = transcriptionCell.buttons["Edit"]
        let deleteButton = transcriptionCell.buttons["Delete"]
        XCTAssertTrue(editButton.exists, "Edit button should exist when swiping left")
        XCTAssertTrue(deleteButton.exists, "Delete button should exist when swiping left")

        // Test the Edit action
        editButton.tap()
        let transcriptionTextView = app.textViews["transcriptionTextView"]
        XCTAssertTrue(transcriptionTextView.waitForExistence(timeout: 5), "Transcription text view should appear after tapping Edit")

        // Go back to the list
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }
} 