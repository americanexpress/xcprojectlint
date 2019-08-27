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

final class DiskLayoutMatchesProjectTests: XCTestCase {
  func test_diskLayoutIsGood_returnsClean() {
    do {
      let testData = Bundle.test.testData(.good)
      let errorReporter = ErrorReporter(pbxprojPath: testData, reportKind: .error)
      let project = try Project(testData, errorReporter: errorReporter)

      XCTAssertEqual(diskLayoutMatchesProject(project, errorReporter: errorReporter, skipFolders: ["Products"]), EX_OK)
    } catch {
      print(error.localizedDescription)
      XCTFail("Failed to initialize test")
    }
  }

  func test_diskLayoutMatchesProject_returnsError() {
    do {
      let testData = Bundle.test.testData()
      let errorReporter = ErrorReporter(pbxprojPath: testData, reportKind: .error)
      let project = try Project(testData, errorReporter: errorReporter)

      XCTAssertEqual(diskLayoutMatchesProject(project, errorReporter: errorReporter, skipFolders: ["Products"]), EX_SOFTWARE)
    } catch {
      print(error.localizedDescription)
      XCTFail("Failed to initialize test")
    }
  }
}
