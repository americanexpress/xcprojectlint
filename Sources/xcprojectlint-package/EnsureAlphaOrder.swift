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

private enum SortOrder {
  case byName
  case `default`

  func sort(fileNames: [String], groupNames: [String]) -> [String] {
    switch self {
    case .byName:
      return (groupNames + fileNames).sorted {
        $0.localizedStandardCompare($1) == .orderedAscending
      }
    case .default:
      return groupNames.sorted { $0.localizedStandardCompare($1) == .orderedAscending }
        + fileNames.sorted { $0.localizedStandardCompare($1) == .orderedAscending }
    }
  }
}

private func validateThisGroup(_ id: String, title: String, project: Project, logEntry: String, sortOrder: SortOrder) -> String? {
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

  let sortedArray = sortOrder.sort(fileNames: fileNames, groupNames: groupNames)

  let matches = allNames == sortedArray
  if !matches {
    return "\(logEntry) Xcode folder “\(pathToParent)/\(title)” has out-of-order children.\nExpected: \(sortedArray)\nActual:   \(allNames)\n"
  }

  return nil
}

private func recurseLookingForOrder(_ groups: [String], project: Project, logEntry: String, sortOrder: SortOrder) -> [String] {
  return groups.flatMap { id -> [String] in
    guard let group = project.groups[id] else {
      return []
    }

    let error = validateThisGroup(id, title: group.title, project: project, logEntry: logEntry, sortOrder: sortOrder)
    let errors = recurseLookingForOrder(group.children, project: project, logEntry: logEntry, sortOrder: sortOrder)
    return errors + [error].compactMap { $0 }
  }
}

public func ensureAlphaOrder(_ project: Project, logEntry: String, sortByName: Bool, skipFolders: [String]?) -> Report {
  guard let proj = project.projectNodes.first,
    var children = project.groups[proj.mainGroup]?.children else {
    return .invalidInput
  }

  if let skipFolders = skipFolders, !skipFolders.isEmpty {
    children.removeAll { skipFolders.contains(project.groups[$0]?.name ?? "") }
  }

  let sortOrder: SortOrder = sortByName ? .byName : .default

  let errors = recurseLookingForOrder(children, project: project, logEntry: logEntry, sortOrder: sortOrder)
  return errors.isEmpty ? .passed : .failed(errors: errors)
}
