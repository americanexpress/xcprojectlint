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

public func checkForWhiteSpaceSpecifications(_ project: Project, errorReporter: ErrorReporter) -> Int32 {
  let toGroupError: (String, String) -> (String) -> String = { groupID, type in
    { _ in
      "\(errorReporter.reportKind.logEntry) Group item (\(groupID)) contains white space specification of '\(type)'.\n "
    }
  }

  let groupsErrors = project.groups.values.flatMap { group -> [String] in
    [
      group.tabWidth.map(toGroupError(group.id, "tabWidth")),
      group.indentWidth.map(toGroupError(group.id, "indentWidth")),
      group.usesTabs.map(toGroupError(group.id, "usesTabs")),
    ].compactMap { $0 }
  }

  let toFileError: (FileReference, String) -> (String) -> String = { fileReference, type in
    { _ in
      "\(project.absolutePathToReference(fileReference)):0:\(errorReporter.reportKind.logEntry) File “\(fileReference.title)” (\(fileReference.id)) contains white space specification of '\(type)'.\n"
    }
  }

  let fileReferenceErrors = project.fileReferences.values.flatMap { fileReference -> [String] in
    [
      fileReference.tabWidth.map(toFileError(fileReference, "tabWidth")),
      fileReference.indentWidth.map(toFileError(fileReference, "indentWidth")),
      fileReference.lineEnding.map(toFileError(fileReference, "lineEnding")),
    ].compactMap { $0 }
  }

  let allErrors = groupsErrors + fileReferenceErrors

  for error in allErrors {
    ErrorReporter.report(error)
  }

  return allErrors.isEmpty ? EX_OK : errorReporter.reportKind.returnType
}
