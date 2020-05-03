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
import XcodeProj
import PathKit

final class MissingTargetReferencesInSchemeTests: XCTestCase {
  func test_missingTargetReferencesInScheme_returnsFailed() {
    do {
      let projectPathString = Bundle.test.testData()
      let badWorkspacePath = Bundle.test.testWorkspace()
      let errorReporter = ErrorReporter(pbxprojPath: projectPathString, reportKind: .error)
      
      let workspace = try XCWorkspace(path: Path(badWorkspacePath))
      let report = missingTargetReferencesInSchemes(
        workspace: workspace,
        logEntry: errorReporter.reportKind.logEntry
      )
      XCTAssertEqual(
        report,
        .failed(errors:
          [
            "Target defined in Good.xcodeproj is referenced in scheme. But Good.xcodeproj is missing from workspace."
          ]
        )
      )
    } catch {
      print(error.localizedDescription)
      XCTFail("Failed to initialize test")
    }
  }
}
