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

final class WhiteSpaceSpecificationTests: XCTestCase {
  func test_whiteSpaceSpecifiersAreAbsent_returnsClean() {
    do {
      let testData = Bundle.test.testData(.good)
      let errorReporter = ErrorReporter(pbxprojPath: testData, reportKind: .error)
      let project = try Project(testData, errorReporter: errorReporter)

      let report = checkForWhiteSpaceSpecifications(project, logEntry: errorReporter.reportKind.logEntry)
      XCTAssertEqual(report, .passed)
    } catch {
      print(error.localizedDescription)
      XCTFail("Failed to initialize test")
    }
  }

  func test_whiteSpaceSpecifiersArePresent_returnsError() {
    do {
      let testData = Bundle.test.testData()
      let testDataPath = Bundle.test.testDataRoot.path
      let errorReporter = ErrorReporter(pbxprojPath: testData, reportKind: .error)
      let project = try Project(testData, errorReporter: errorReporter)

      let report = checkForWhiteSpaceSpecifications(project, logEntry: errorReporter.reportKind.logEntry)
      let expectedErrors = [
        "error: Group item (D2A90D172032191C00EBA6AA) contains white space specification of \'wrapsLines\'.\n ",
        "error: Group item (D2CAE8752031EE5F00F76063) contains white space specification of \'indentWidth\'.\n ",
        "error: Group item (D2CAE8752031EE5F00F76063) contains white space specification of \'tabWidth\'.\n ",
        "error: Group item (D2CAE8752031EE5F00F76063) contains white space specification of \'usesTabs\'.\n ",
        "\(testDataPath)/Bad/ItemsOutOfOrder/First.swift:0:error: File “First.swift” (D2A90D132032190A00EBA6AA) contains white space specification of \'wrapsLines\'.\n",
        "\(testDataPath)/Bad/ItemsOutOfOrder/Second.swift:0:error: File “Second.swift” (D2A90D152032191600EBA6AA) contains white space specification of \'indentWidth\'.\n",
        "\(testDataPath)/Bad/ItemsOutOfOrder/Second.swift:0:error: File “Second.swift” (D2A90D152032191600EBA6AA) contains white space specification of \'lineEnding\'.\n",
        "\(testDataPath)/Bad/ItemsOutOfOrder/Second.swift:0:error: File “Second.swift” (D2A90D152032191600EBA6AA) contains white space specification of \'tabWidth\'.\n",
        "\(testDataPath)/Bad/ItemsOutOfOrder/Second.swift:0:error: File “Second.swift” (D2A90D152032191600EBA6AA) contains white space specification of \'wrapsLines\'.\n",
      ]
      XCTAssertEqual(report.errors, expectedErrors)
    } catch {
      print(error.localizedDescription)
      XCTFail("Failed to initialize test")
    }
  }
}
