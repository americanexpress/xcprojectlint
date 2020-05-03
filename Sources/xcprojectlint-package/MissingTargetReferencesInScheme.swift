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
import PathKit
import XcodeProj

public func missingTargetReferencesInScheme(workspace: XCWorkspace, logEntry: String) -> Report {
  let entries: [String] = workspace.data..schemes
    .compactMap { $0.buildAction?.buildActionEntries }
    .joined()
    .map { $0.buildableReference.referencedContainer }
    .compactMap {
      guard let regex = try? NSRegularExpression(pattern: "\\w*\\.xcodeproj", options: .caseInsensitive) else { return nil }
      let range = NSRange(
        location: 0,
        length: $0.utf16.count
      )
      
      if let match = regex.firstMatch(in: $0, options: [], range: range) {
        if let swiftRange = Range(match.range, in: $0) {
            return String($0[swiftRange])
        } else {
          return nil
        }
      } else {
        return nil
      }
  }
  
  let scheme = schemes[1]
  let entry = scheme.buildAction?.buildActionEntries[0]
  let buildableReference = entry?.buildableReference
  func getFiles(for element: XCWorkspaceDataElement) -> [XCWorkspaceDataFileRef] {
    switch element {
    case let .file(file):
      return [file]
    case let .group(group):
      return group.children.flatMap(getFiles)
    }
  }
  let files = workspace.data.children.flatMap(getFiles).map { $0.location }
  
  return .passed
}

extension XCWorkspaceDataFileRef: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.location.description)
  }
}
