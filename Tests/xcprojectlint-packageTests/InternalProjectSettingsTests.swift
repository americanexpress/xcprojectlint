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

final class InternalProjectSettingsTests: XCTestCase {
  func test_containsNoInternalProjectSettings_returnsClean() {
    do {
      let testData = Bundle.test.testData(.good)
      let errorReporter = ErrorReporter(pbxprojPath: testData, reportKind: .error)
      let project = try Project(testData, errorReporter: errorReporter)
      let report = checkForInternalProjectSettings(
        project,
        pbxprojPath: errorReporter.pbxprojPath,
        logEntry: errorReporter.reportKind.logEntry
      )
      XCTAssertEqual(report, .passed)
    } catch {
      print(error.localizedDescription)
      XCTFail("Failed to initialise test")
    }
  }

  func test_containsInternalProjectSettings_returnsError() {
    do {
      let testData = Bundle.test.testData()
      let errorReporter = ErrorReporter(pbxprojPath: testData, reportKind: .error)
      let project = try Project(testData, errorReporter: errorReporter)
      let projectPath = project.url.path
      let expectedErrors = [
        "\(projectPath):251: error: Debug has settings defined at the project level.\n",
        "\(projectPath):271: error: Release has settings defined at the project level.\n",
        "\(projectPath):290: error: Debug has settings defined at the project level.\n",
        "\(projectPath):347: error: Release has settings defined at the project level.\n",
        "\(projectPath):396: error: Debug has settings defined at the project level.\n",
        "\(projectPath):406: error: Release has settings defined at the project level.\n",
      ]
      let report = checkForInternalProjectSettings(
        project,
        pbxprojPath: errorReporter.pbxprojPath,
        logEntry: errorReporter.reportKind.logEntry
      )
      XCTAssertEqual(report.errors, expectedErrors)
    } catch {
      print(error.localizedDescription)
      XCTFail("Failed to initialize test")
    }
  }
}
