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

public func checkForDanglingSourceFiles(_ project: Project, logEntry: String) -> Report {
  let targetFiles = Set(project.buildFiles.map { $1.fileRef })
  let extensionsWhiteList = Set(["m", "mm", "swift", "cpp", "c"])

  let errors = project.fileReferences.values
    .compactMap { fileRef -> String? in
      guard let fileExtension = fileRef.title.components(separatedBy: ".").last else { return nil }

      let shouldReport = extensionsWhiteList.contains(fileExtension) && !targetFiles.contains(fileRef.id)
      if shouldReport {
        return "\(project.absolutePathToReference(fileRef)):0: \(logEntry) \(fileRef.path) is not added to any target.\n"
      } else {
        return nil
      }
    }
  return errors.isEmpty ? .passed : .failed(errors: errors)
}
