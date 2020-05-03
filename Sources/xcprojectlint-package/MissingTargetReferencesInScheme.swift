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
import XcodeProj

public func missingTargetReferencesInSchemes(workspace: XCWorkspace) -> Report {
  func getAllFiles(in element: XCWorkspaceDataElement) -> [XCWorkspaceDataFileRef] {
    switch element {
    case let .file(file):
      return [file]
    case let .group(group):
      return group.children.flatMap(getAllFiles)
    }
  }
  guard let schemes = workspace.sharedData?.schemes, !schemes.isEmpty else {
    return .passed
  }
  let referencedProjects = getProjectsReferenced(in: schemes)
  
  let containedProjectPaths = Set(
    workspace.data
      .children
      .flatMap(getAllFiles)
      .map { $0.location.path }
  )
  let errors: [String] = referencedProjects
    .compactMap {
      let error = "Target defined in \($0) is referenced in scheme. But \($0) is missing from workspace."
      return !containedProjectPaths.contains($0) ? error : nil
  }
  
  return errors.isEmpty ? .passed : .failed(errors: errors)
}

private func getProjectsReferenced(in schemes: [XCScheme]) -> [String] {
  schemes
    .compactMap { $0.buildAction?.buildActionEntries }
    .joined()
    .map { $0.buildableReference.referencedContainer }
    .map { $0.dropFirst("container:".count) }
    .map(String.init)
}
