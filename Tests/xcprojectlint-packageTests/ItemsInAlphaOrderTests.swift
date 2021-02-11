/*
 * Copyright (c) 2018 American Express Travel Related Services Company, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License. You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License
 * is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
 * or implied. See the License for the specific language governing permissions and limitations under
 * the License.
 */

@testable import xcprojectlint_package
import XCTest

final class ItemsInAlphaOrderTests: XCTestCase {
  func test_sortedGroup_returnsClean() {
    do {
      let testData = Bundle.test.testData(.good)
      let errorReporter = ErrorReporter(pbxprojPath: testData, reportKind: .error)
      let project = try Project(testData, errorReporter: errorReporter)
      let report = ensureAlphaOrder(
        project,
        logEntry: errorReporter.reportKind.logEntry,
        sortByName: false,
        skipFolders: nil
      )
      XCTAssertEqual(report, .passed)
    } catch {
      print(error.localizedDescription)
      XCTFail("Failed to initialise test")
    }
  }

  func test_sortedGroup_returnsErrors_whenExpectingSortByName() {
    do {
      let testData = Bundle.test.testData(.good)
      let errorReporter = ErrorReporter(pbxprojPath: testData, reportKind: .error)
      let project = try Project(testData, errorReporter: errorReporter)
      let report = ensureAlphaOrder(
        project,
        logEntry: errorReporter.reportKind.logEntry,
        sortByName: true,
        skipFolders: ["Products"]
      )
      let expectedErrors = [
        """
        error: Xcode folder “/Good” has out-of-order children.
        Expected: ["AppDelegate.swift", "Assets.xcassets", "Info.plist", "main.swift", "ViewController.swift", "xcconfigs"]
        Actual:   ["xcconfigs", "AppDelegate.swift", "Assets.xcassets", "Info.plist", "main.swift", "ViewController.swift"]

        """,
      ]

      XCTAssertEqual(report.errors, expectedErrors)
    } catch {
      print(error.localizedDescription)
      XCTFail("Failed to initialise test")
    }
  }

  func test_unorderedGroup_returnsError() {
    do {
      let testData = Bundle.test.testData()
      let errorReporter = ErrorReporter(pbxprojPath: testData, reportKind: .error)
      let project = try Project(testData, errorReporter: errorReporter)
      let expectedErrors = [
        """
        error: Xcode folder “Bad/ItemsOutOfOrder” has out-of-order children.
        Expected: ["First.swift", "Second.swift"]
        Actual:   ["Second.swift", "First.swift"]

        """,
        """
        error: Xcode folder “/Bad” has out-of-order children.
        Expected: ["ItemsOutOfOrder", "MisplacedFile", "MissingFile", "ThisGroupIsEmpty", "main.swift"]
        Actual:   ["ItemsOutOfOrder", "main.swift", "MisplacedFile", "MissingFile", "ThisGroupIsEmpty"]

        """,
      ]
      let report = ensureAlphaOrder(
        project,
        logEntry: errorReporter.reportKind.logEntry,
        sortByName: false,
        skipFolders: ["Products"]
      )
      XCTAssertEqual(report.errors, expectedErrors)
    } catch {
      print(error.localizedDescription)
      XCTFail("Failed to initialize test")
    }
  }
}
