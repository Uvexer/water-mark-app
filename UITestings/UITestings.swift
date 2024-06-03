import XCTest

class WatermarkUITest: XCTestCase {
    
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    func testWatermarkTextFieldExists() {
        let watermarkTextField = app.textFields.firstMatch
        XCTAssertTrue(watermarkTextField.exists)
    }

    func testSaveButtonExists() {
        let saveButton = app.buttons["Сохранить"]
        XCTAssertTrue(saveButton.exists)
    }

    
    func testInfoButtonExists() {
        let infoButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'info'"))
        XCTAssertTrue(infoButton.firstMatch.exists)
    }


}

