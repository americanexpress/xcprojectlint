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

private func validateThisGroup(_ id: String, title: String, project: Project, errorReporter: ErrorReporter) -> Bool {
  var groupNames = [String]()
  var fileNames = [String]()
  var allNames = [String]()
  let pathToParent = project.pathToReference(id)
  if let parent = project.groups[id] {
    for child in parent.children {
      if let group = project.groups[child] {
        groupNames.append(group.title)
        allNames.append(group.title)
      } else if let file = project.fileReferences[child] {
        fileNames.append(file.title)
        allNames.append(file.title)
      }
    }
  }

  let sortedArray = groupNames.sorted {
    (s1, s2) -> Bool in s1.localizedStandardCompare(s2) == .orderedAscending
  }
    + fileNames.sorted {
      (s1, s2) -> Bool in s1.localizedStandardCompare(s2) == .orderedAscending
    }

  let matches = allNames == sortedArray
  if !matches {
    let errStr = "\(errorReporter.reportKind.logEntry) Xcode folder “\(pathToParent)/\(title)” has out-of-order children.\nExpected: \(sortedArray)\nActual:   \(allNames)"
    print(errStr)
  }

  return matches
}

private func recurseLookingForOrder(_ groups: [String], project: Project, prevResult: Int32, errorReporter: ErrorReporter) -> Int32 {
  var result = prevResult
  for child in groups {
    if let group = project.groups[child] {
      if !validateThisGroup(child, title: group.title, project: project, errorReporter: errorReporter) {
        result = errorReporter.reportKind.returnType
      }
      result = recurseLookingForOrder(group.children, project: project, prevResult: result, errorReporter: errorReporter)
    }
  }

  return result
}

public func ensureAlphaOrder(_ project: Project, errorReporter: ErrorReporter) -> Int32 {
  var result = EX_DATAERR
  if let proj = project.projectNodes.first {
    let mainGroup = proj.mainGroup
    let group = project.groups[mainGroup]

    if let children = group?.children {
      result = recurseLookingForOrder(children, project: project, prevResult: EX_OK, errorReporter: errorReporter)
    }
  }

  return result
}
