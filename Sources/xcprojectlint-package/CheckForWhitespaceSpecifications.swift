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
  var errors: [String] = []
  var scriptResult = EX_OK

  for namedGroup in project.groups.keys {
    guard let group = project.groups[namedGroup] else { continue }
    if group.tabWidth != nil || group.indentWidth != nil || group.usesTabs != nil {
      errors.append("\(errorReporter.reportKind.logEntry) Group item (\(group.id)) contains whitespace specification.\n")

      scriptResult = EX_DATAERR
    }
  }

  for namedFileReference in project.fileReferences.keys {
    guard let fileReference = project.fileReferences[namedFileReference] else { continue }
    if fileReference.tabWidth != nil || fileReference.indentWidth != nil || fileReference.lineEnding != nil {
      errors.append("\(errorReporter.reportKind.logEntry) File “\(fileReference.title)” (\(fileReference.id)) contains whitespace specification.\n")

      scriptResult = EX_DATAERR
    }
  }

  for error in errors {
    ErrorReporter.report(error)
  }

  return (scriptResult)
}
