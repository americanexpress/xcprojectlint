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

  for group in project.groups.values {
    if group.tabWidth != nil {
      errors.append("\(errorReporter.reportKind.logEntry) Group item (\(group.id)) contains white space specification of 'tabWidth'.\n ")

      scriptResult = errorReporter.reportKind.returnType
    }

    if group.indentWidth != nil {
      errors.append("\(errorReporter.reportKind.logEntry) Group item (\(group.id)) contains white space specification of 'indentWidth'.\n ")

      scriptResult = errorReporter.reportKind.returnType
    }

    if group.usesTabs != nil {
      errors.append("\(errorReporter.reportKind.logEntry) Group item (\(group.id)) contains white space specification of 'usesTabs'.\n ")

      scriptResult = errorReporter.reportKind.returnType
    }
  }

  for fileReference in project.fileReferences.values {
    if fileReference.tabWidth != nil {
      errors.append("\(project.absolutePathToReference(fileReference)):0:\(errorReporter.reportKind.logEntry) File “\(fileReference.title)” (\(fileReference.id)) contains white space specification of 'tabWidth'.\n")

      scriptResult = errorReporter.reportKind.returnType
    }
    if fileReference.indentWidth != nil {
      errors.append("\(project.absolutePathToReference(fileReference)):0:\(errorReporter.reportKind.logEntry) File “\(fileReference.title)” (\(fileReference.id)) contains white space specification of 'indentWidth'.\n")

      scriptResult = errorReporter.reportKind.returnType
    }
    if fileReference.lineEnding != nil {
      errors.append("\(project.absolutePathToReference(fileReference)):0:\(errorReporter.reportKind.logEntry) File “\(fileReference.title)” (\(fileReference.id)) contains white space specification of 'lineEnding'.\n")

      scriptResult = errorReporter.reportKind.returnType
    }
  }

  for error in errors {
    ErrorReporter.report(error)
  }

  return (scriptResult)
}
