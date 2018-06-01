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

private func recurseForMisplacedFiles(_ groups: [String], project: Project, errors: Set<String>, errorReporter: ErrorReporter) -> Set<String> {
  var errors = errors
  for child in groups {
    if let group = project.groups[child] {
      if groupExcluded(group) {
        continue
      }
      if group.name != nil {
        let errStr = "\(errorReporter.reportKind.logEntry) Folder “\(group.title)” (\(group.id)) is misplaced on disk, or wrong kind of reference.\n"
        errors.insert(errStr)
        // Once we've found a detached parent, none of the children need to be looked at; they're detached, too.
        continue
      }
      errors = recurseForMisplacedFiles(group.children, project: project, errors: errors, errorReporter: errorReporter)
    } else if let file = project.fileReferences[child] {
      if file.name != nil {
        let errStr = "\(errorReporter.reportKind.logEntry) File “\(file.title)” (\(file.id)) is misplaced on disk, or wrong kind of reference.\n"
        errors.insert(errStr)
      }
    }
  }
  return errors
}

private func groupExcluded(_ group: Group) -> Bool {
  guard let name = group.name,
  let skipFolders = skkipFolders else { return false }
  return skipFolders.contains(name)
}

var skkipFolders: [String]?

public func diskLayoutMatchesProject(_ project: Project, errorReporter: ErrorReporter, skipFolders: [String]?) -> Int32 {
  skkipFolders = skipFolders
  var result = EX_DATAERR
  if let proj = project.projectNodes.first {
    let mainGroup = proj.mainGroup
    let group = project.groups[mainGroup]
    
    let errors = Set<String>()
    if let children = group?.children {
      let results = recurseForMisplacedFiles(children, project: project, errors: errors, errorReporter: errorReporter).sorted()
      
      if results.count > 0 {
        result = errorReporter.reportKind.returnType
        for error in results {
          ErrorReporter.report(error)
        }
      } else {
        result = EX_OK
      }
    }
  }
  
  return result
}
