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

import Darwin
import Foundation

private func validateThisGroup(_ id: String, title: String, project: Project, errorReporter: ErrorReporter) -> Bool {
  let pathToParent = project.pathToReference(id)
  if let parent = project.groups[id] {
    if parent.children.isEmpty {
      let errStr = "\(errorReporter.reportKind.logEntry) Xcode folder “\(pathToParent)/\(title)” has no children."
      print(errStr)
      return false
    }
  }
  return true
}

private func recurseLookingForEmpties(_ groups: [String], project: Project, prevResult: Int32, errorReporter: ErrorReporter) -> Int32 {
  var result = prevResult
  for child in groups {
    if let group = project.groups[child] {
      if !validateThisGroup(child, title: group.title, project: project, errorReporter: errorReporter) {
        result = errorReporter.reportKind.returnType
      }
      result = recurseLookingForEmpties(group.children, project: project, prevResult: result, errorReporter: errorReporter)
    }
  }
  
  return result
}

public func noEmptyGroups(_ project: Project, errorReporter: ErrorReporter) -> Int32 {
  var result = EX_DATAERR
  if let proj = project.projectNodes.first {
    let mainGroup = proj.mainGroup
    let group = project.groups[mainGroup]
    
    if let children = group?.children {
      result = recurseLookingForEmpties(children, project: project, prevResult: EX_OK, errorReporter: errorReporter)
    }
  }
  
  return result
}

