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

import Foundation

public struct ErrorReporter {
  public let pbxprojPath: String
  public let reportKind: ReportKind
  
  public init(pbxprojPath: String, reportKind: ReportKind) {
    self.pbxprojPath = pbxprojPath
    self.reportKind = reportKind
  }
  
  public func report(_ error: Error) {
    // NOTE: The spaces around the error: portion of the screen are required with Xcode 8.3. Without them, no output gets reported in the Issue Navigator.
    let errStr = "\(pbxprojPath):0: \(reportKind.logEntry) \(error.localizedDescription)\n"
    ErrorReporter.report(errStr)
  }
  
  public static func report(_ errorString: String) {
    let handle = FileHandle.standardError
    if let data = errorString.data(using: .utf8) {
      handle.write(data)
    }
  }
}

