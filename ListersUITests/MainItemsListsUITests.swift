//
//  MainItemsListsUITests.swift
//  ListersUITests
//
//  Created by Edu Caubilla on 30/7/25.
//

import XCTest

final class MainItemsUITests: XCTestCase {
    var app: XCUIApplication!
    var timeout: TimeInterval = 2

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()

        // Add launch arguments to reset app state for consistent testing
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    override func tearDownWithError() throws {
        uninstall(name: "Listers")
        app = nil
    }

    func uninstall(name: String? = nil) {
        app.terminate()

//        let timeout = TimeInterval(3)
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

        let appName: String
        if let name = name {
            appName = name
        } else {
            let uiTestRunnerName = Bundle.main.infoDictionary?["CFBundleName"] as! String
            appName = uiTestRunnerName.replacingOccurrences(of: "UITests-Runner", with: "")
        }

        /// use `firstMatch` because icon may appear in iPad dock
        let appIcon = springboard.icons[appName].firstMatch
        if appIcon.waitForExistence(timeout: timeout) {
            appIcon.press(forDuration: 2)
        } else {
            XCTFail("Failed to find app icon named \(appName)")
        }

        let removeAppButton = springboard.buttons["Remove App"]
        if removeAppButton.waitForExistence(timeout: timeout + 2) {
            removeAppButton.tap()
        } else {
            XCTFail("Failed to find 'Remove App'")
        }

        let deleteAppButton = springboard.alerts.buttons["Delete App"]
        if deleteAppButton.waitForExistence(timeout: timeout) {
            deleteAppButton.tap()
        } else {
            XCTFail("Failed to find 'Delete App'")
        }

        let finalDeleteButton = springboard.alerts.buttons["Delete"]
        if finalDeleteButton.waitForExistence(timeout: timeout) {
            finalDeleteButton.tap()
        } else {
            XCTFail("Failed to find 'Delete'")
        }
    }

    // MARK: - Test Critical User Flows
    func testCreateFirstListAndAddItem() throws {
        // Test the complete flow from empty state to having items

        // 1. Verify empty state is shown
        let noItemsText = app.staticTexts["empty_state_view"] // MainItemsView:108
        XCTAssertTrue(noItemsText.waitForExistence(timeout: 5))

        // 2. Tap to create first list
        let addCircleIconButton = app.images["empty_state_view"] // MainItemsView:112
        XCTAssertTrue(addCircleIconButton.exists)
        addCircleIconButton.tap()

        // 3. Fill out list form
        let listNameField = app.textFields["list_name_field"] // FormListView:100
        XCTAssertTrue(listNameField.waitForExistence(timeout: timeout))
        listNameField.tap()
        listNameField.typeText("Groceries")

        // 4. Save list
        let saveListButton = app.buttons["save_list_button"] // FormListView:135
        saveListButton.tap()

        // 5. Verify we're now in the list view
        let navigationTitle = app.navigationBars["Groceries"] // MainItemsView:88
        XCTAssertTrue(navigationTitle.waitForExistence(timeout: timeout))

        // 6. Add an item
        let addItemButton = app.buttons["main_items_view"] // MainItemsView:99
        addItemButton.tap()

        // 7. Fill item form
        let itemNameField = app.textFields["item_name_field"] // FormItemView:141
        XCTAssertTrue(itemNameField.waitForExistence(timeout: timeout))
        itemNameField.tap()
        itemNameField.typeText("Milk")

        // 8. Save item
        let saveItemButton = app.buttons["save_item_button"] // FormItemView:240
        saveItemButton.tap()

        // 9. Verify item appears in list
        let milkItem = app.staticTexts["Milk"] // TODO - Check if working
        XCTAssertTrue(milkItem.waitForExistence(timeout: timeout))
    }

    func testEditExistingItem() throws {
        // Ensure we have a list with an item
        createTestListWithItem()

        // 1. Find and swipe right on first item
        let firstItemCell = app.cells.firstMatch
        XCTAssertTrue(firstItemCell.exists)

        // Assuming you have an edit button/action in your ItemRowCellView
        firstItemCell.swipeRight()
        let editButton = app.buttons["edit_item_button"]
        editButton.tap()

        // 2. Modify item name
        let itemNameField = app.textFields["item_name_field"]
        XCTAssertTrue(itemNameField.waitForExistence(timeout: timeout))

        // Clear existing text and type new text
        itemNameField.doubleTap()
        itemNameField.typeText("Bananas")

        // 3. Save changes
        let saveButton = app.buttons["save_item_button"]
        saveButton.tap()

        // 4. Verify updated item appears
        let updatedItem = app.staticTexts["Organic Milk"]
        XCTAssertTrue(updatedItem.waitForExistence(timeout: timeout))
    }

    func testCompleteListFlow() throws {
        // Test the alert flow when list is completed
        createTestListWithItem()

        // 1. Mark item as complete
        let firstItemCell = app.cells.firstMatch
        let completeButton = firstItemCell.switches["complete_item_button"] // Add accessibility identifier
        completeButton.tap()

        // 2. Verify completion alert appears
        let alert = app.alerts.element
        XCTAssertTrue(alert.waitForExistence(timeout: timeout + 1))

        // 3. Test Cancel action
        let cancelButton = alert.buttons["alert_main_items_view_cancel"]
        XCTAssertTrue(cancelButton.exists)
        cancelButton.tap()

        // 4. Verify we're still in the same view
        XCTAssertTrue(app.navigationBars.firstMatch.exists)

        // 5. Complete item again and test OK action
        completeButton.tap() // To uncheck
        completeButton.tap() // Check again
        let okButton = alert.buttons["alert_main_items_view_ok"]
        okButton.tap()

        // 6. Verify navigation to lists view
        let listsViewTitleBar = app.navigationBars["My lists"]
        XCTAssertTrue(listsViewTitleBar.waitForExistence(timeout: timeout))
    }

    func testSwipeNavigationToLists() throws {
        // Ensure we have a list with an item
        createTestListWithItem()

        // Test the swipe gesture to navigate to lists
        let mainView = app.collectionViews["main_items_view"]
        mainView.swipeLeft()

        // Verify we navigated to lists view
        let listsViewTitleBar = app.navigationBars["My lists"]
        XCTAssertTrue(listsViewTitleBar.waitForExistence(timeout: timeout))
    }

    func testSwipeNavigationFromListsToMain() throws {
        // Ensure we have a list with an item
        createTestListWithItem()

        //Swipe to Lists View
        let mainView = app.collectionViews["main_items_view"]
        mainView.swipeLeft()

        // Verify navigation to lists view
        let listsViewTitleBar = app.navigationBars["My lists"]
        XCTAssertTrue(listsViewTitleBar.waitForExistence(timeout: timeout + 2))

        // Test the swipe gesture to navigate to main view
        let listsView = app.collectionViews["lists_view"]
        listsView.swipeRight()

        // Verify we navigated to main view
        let mainViewBack = app.collectionViews.firstMatch
        XCTAssertTrue(mainViewBack.waitForExistence(timeout: timeout))
    }

    func testEmptyStateInteraction() throws {
        // Test interaction with empty state
        let noItemsText = app.staticTexts["empty_state_view"]
        XCTAssertTrue(noItemsText.waitForExistence(timeout: timeout))

        // Tap the empty message
        let emptyStateText = app.staticTexts["empty_state_view"]
        emptyStateText.tap()

        // Verify list creation form opens
        let listNameField = app.textFields["list_name_field"]
        XCTAssertTrue(listNameField.waitForExistence(timeout: timeout))
    }

    // MARK: - Helper Methods

    private func createTestListWithItem() {
        // Helper method to set up test data
        let noItemsText = app.staticTexts["empty_state_view"]
        if noItemsText.waitForExistence(timeout: 1) {
            // Create list
            app.images["empty_state_view"].tap()

            let listNameField = app.textFields["list_name_field"]
            listNameField.tap()
            listNameField.typeText("Test List")

            app.buttons["save_list_button"].tap()

            // Add item
            app.buttons["main_items_view"].tap()

            let itemNameField = app.textFields["item_name_field"]
            itemNameField.tap()
            itemNameField.typeText("TestItem")

            app.buttons["save_item_button"].tap()
        }
    }
}

// MARK: - Additional Test Class for Performance Testing
final class MainItemsPerformanceTests: XCTestCase {

    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

//    func testScrollPerformanceWithManyItems() throws {
//        let app = XCUIApplication()
//        app.launchArguments = ["--uitesting", "--populate-large-list"]
//        app.launch()
//
//        // Measure scrolling performance with many items
//        let list = app.tables.firstMatch
//        XCTAssertTrue(list.waitForExistence(timeout: 5))
//
//        measure {
//            list.swipeUp()
//            list.swipeDown()
//        }
//    }
}
