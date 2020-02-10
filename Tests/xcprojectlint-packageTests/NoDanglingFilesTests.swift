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

class NoDanglingSourceFilesTests: XCTestCase {
  func test_sourceFilesPresentInProject_returnsClean() {
    do {
      let testData = Bundle.test.testData(.good)
      let errorReporter = ErrorReporter(pbxprojPath: testData, reportKind: .error)
      let project = try Project(testData, errorReporter: errorReporter)
      let report = checkForDanglingSourceFiles(project, logEntry: errorReporter.reportKind.logEntry)
      XCTAssertEqual(report, .passed)
    } catch {
      print(error.localizedDescription)
      XCTFail("Failed to initialise test")
    }
  }

  func test_danglingSourceFiles_returnsError() {
    do {
      let testData = Bundle.test.testData()
      let testDataPath = Bundle.test.testDataRoot.path
      let errorReporter = ErrorReporter(pbxprojPath: testData, reportKind: .error)
      let project = try Project(testData, errorReporter: errorReporter)
      let expectedErrors = [
        "\(testDataPath)/BadUnitTests/DanglingFile/BadUnitTests.swift:0: error: BadUnitTests.swift is not added to any target.\n",
      ]
      let report = checkForDanglingSourceFiles(project, logEntry: errorReporter.reportKind.logEntry)
      XCTAssertEqual(report.errors, expectedErrors)
    } catch {
      print(error.localizedDescription)
      XCTFail("Failed to initialize test")
    }
  }
}
