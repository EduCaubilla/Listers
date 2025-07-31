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

//    func testingFlow() {
//        let app = XCUIApplication()
//        app.activate()
//        app/*@START_MENU_TOKEN@*/.images["main_items_add_icon_circle"]/*[[".otherElements",".images[\"Add\"]",".images[\"main_items_add_icon_circle\"]",".images.firstMatch"],[[[-1,2],[-1,1],[-1,3],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
//        app/*@START_MENU_TOKEN@*/.buttons["save_list_button"]/*[[".otherElements",".buttons[\"Save\"]",".buttons[\"save_list_button\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
//        app/*@START_MENU_TOKEN@*/.buttons["main_items_view_add"]/*[[".buttons",".containing(.staticText, identifier: \"Add item\").firstMatch",".containing(.image, identifier: \"plus\").firstMatch",".otherElements",".buttons[\"Add item\"]",".buttons[\"main_items_view_add\"]"],[[[-1,5],[-1,4],[-1,3,2],[-1,0,1]],[[-1,2],[-1,1]],[[-1,5],[-1,4]]],[0]]@END_MENU_TOKEN@*/.tap()
//        app/*@START_MENU_TOKEN@*/.textFields["item_name_field"]/*[[".otherElements",".textFields[\"Add name\"]",".textFields[\"item_name_field\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
//        app/*@START_MENU_TOKEN@*/.buttons["save_item_button"]/*[[".otherElements",".buttons[\"Save\"]",".buttons[\"save_item_button\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
//        
//        let elementsQuery = app.otherElements
//        elementsQuery.matching(identifier: "Horizontal scroll bar, 1 page").element(boundBy: 1).tap()
//        app/*@START_MENU_TOKEN@*/.staticTexts["31 July 2025"]/*[[".otherElements.staticTexts[\"31 July 2025\"]",".staticTexts[\"31 July 2025\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
//        app/*@START_MENU_TOKEN@*/.switches["complete_item_button"]/*[[".otherElements",".switches[\"circle\"]",".switches[\"complete_item_button\"]",".switches.firstMatch"],[[[-1,2],[-1,1],[-1,3],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
//        app/*@START_MENU_TOKEN@*/.buttons["alert_main_items_view_ok"]/*[[".otherElements",".buttons[\"Ok\"]",".buttons[\"alert_main_items_view_ok\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
//        elementsQuery/*@START_MENU_TOKEN@*/.containing(.other, identifier: "SystemInputAssistantView").firstMatch/*[[".element(boundBy: 3)",".containing(.other, identifier: \"CenterPageView\").firstMatch",".containing(.keyboard, identifier: nil).firstMatch",".containing(.other, identifier: \"SystemInputAssistantView\").firstMatch"],[[[-1,3],[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
//
//        app.activate()
//        app.collectionViews/*@START_MENU_TOKEN@*/.firstMatch/*[[".containing(.cell, identifier: nil).firstMatch",".containing(.other, identifier: nil).firstMatch",".firstMatch"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeLeft()
//        app/*@START_MENU_TOKEN@*/.otherElements["Vertical scroll bar, 1 page"]/*[[".collectionViews.otherElements[\"Vertical scroll bar, 1 page\"]",".otherElements[\"Vertical scroll bar, 1 page\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeLeft()
//        app/*@START_MENU_TOKEN@*/.collectionViews["lists_view"]/*[[".otherElements.collectionViews[\"lists_view\"]",".collectionViews",".containing(.cell, identifier: nil).firstMatch",".containing(.other, identifier: nil).firstMatch",".firstMatch",".collectionViews[\"lists_view\"]"],[[[-1,5],[-1,1,1],[-1,0]],[[-1,4],[-1,3],[-1,2]]],[0]]@END_MENU_TOKEN@*/.swipeRight()
//

//        let app = XCUIApplication()
//        app.activate()
//        let mainItemsViewCollectionView = app/*@START_MENU_TOKEN@*/.collectionViews["main_items_view"]/*[[".otherElements.collectionViews[\"main_items_view\"]",".collectionViews",".containing(.cell, identifier: nil).firstMatch",".containing(.other, identifier: nil).firstMatch",".firstMatch",".collectionViews[\"main_items_view\"]"],[[[-1,5],[-1,1,1],[-1,0]],[[-1,4],[-1,3],[-1,2]]],[0]]@END_MENU_TOKEN@*/
//        mainItemsViewCollectionView.swipeLeft()
//        mainItemsViewCollectionView.swipeLeft()
//        mainItemsViewCollectionView.swipeLeft()
//        app/*@START_MENU_TOKEN@*/.collectionViews["lists_view"]/*[[".otherElements.collectionViews[\"lists_view\"]",".collectionViews",".containing(.cell, identifier: nil).firstMatch",".containing(.other, identifier: nil).firstMatch",".firstMatch",".collectionViews[\"lists_view\"]"],[[[-1,5],[-1,1,1],[-1,0]],[[-1,4],[-1,3],[-1,2]]],[0]]@END_MENU_TOKEN@*/.swipeRight()
//        mainItemsViewCollectionView.swipeLeft()
        
//    }

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
