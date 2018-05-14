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

public struct Project {
  let projectName: String
  let url: URL
  let projectText: String
  
  let buildConfigurationLists: Dictionary<String, BuildConfigurationList>
  let buildConfigurations: [BuildConfiguration]
  let buildFiles: Dictionary<String, BuildFile>
  let containerItemProxies: [ContainerItemProxy]
  let copyFilesPhases: [CopyFilesBuildPhase]
  let fileReferences: Dictionary<String, FileReference>
  let frameworksBuildPhases: [FrameworksBuildPhase]
  let groups: Dictionary<String, Group>
  let legacyTargets: [LegacyTarget]
  let nativeTargets: [NativeTarget]
  let projectNodes: [ProjectNode]
  let resourceBuildPhases: [ResourcesBuildPhase]
  let shellScriptBuildPhases: [ShellScriptBuildPhase]
  let sourcesBuildPhases: [SourcesBuildPhase]
  let targetDependencies: [TargetDependency]
  let titles: Dictionary<String, String>
  let variantGroups: [VariantGroup]
  
  public init(_ projectPath: String, errorReporter: ErrorReporter) throws {
    let filename = "project.pbxproj"
    let projectURL = URL(fileURLWithPath: projectPath)
    let url = projectURL.appendingPathComponent(filename)
        
    guard let data = try? Data(contentsOf: url) else { throw ProjectParseError.failedToReadProjectFile }
    guard let projectText = String(data: data, encoding: .utf8) else { throw ProjectParseError.failedToInflateProjectFile }
    guard let serialization = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [AnyHashable : Any] else { throw ProjectParseError.failedToSerializeProjectData }
    guard let plist = serialization else { throw ProjectParseError.failedToSerializeProjectData }
    guard let dict = NSDictionary(dictionary: plist) as? Dictionary<String, Any> else { throw ProjectParseError.failedToContortDictionary }
    
    let parser = ProjectParser(project: dict, projectText: projectText, projectPath: projectPath)
    guard parser.parse() else { throw ProjectParseError.failedToParseProjectStructure }
    
    self.projectName = projectURL.lastPathComponent
    self.url = url
    self.projectText = projectText
    
    self.buildConfigurationLists = parser.buildConfigurationLists
    self.buildConfigurations = parser.buildConfigurations
    self.buildFiles = parser.buildFiles
    self.containerItemProxies = parser.containerItemProxies
    self.copyFilesPhases = parser.copyFilesPhases
    self.fileReferences = parser.fileReferences
    self.frameworksBuildPhases = parser.frameworksBuildPhases
    self.groups = parser.groups
    self.legacyTargets = parser.legacyTargets
    self.nativeTargets = parser.nativeTargets
    self.projectNodes = parser.projectNodes
    self.resourceBuildPhases = parser.resourceBuildPhases
    self.shellScriptBuildPhases = parser.shellScriptBuildPhases
    self.sourcesBuildPhases = parser.sourcesBuildPhases
    self.targetDependencies = parser.targetDependencies
    self.titles = parser.titles
    self.variantGroups = parser.variantGroups
  }
  
  func parentForObject(_ objectID: String) -> TitledNode? {
    let parent = groups.filter { $0.value.children.contains(objectID) }
    guard let result = parent.first else { return nil }
    
    return result.value
  }
  
  func absolutePathToReference(_ fileReference: FileReference) -> String {
    // trim back to the parent directory
    var path = url.deletingLastPathComponent().deletingLastPathComponent()
    path.appendPathComponent(pathToReference(fileReference.id))
    path.appendPathComponent(fileReference.title)
    return path.path
  }
  
  func pathToReference(_ objectID: String) -> String {
    var segment = parentForObject(objectID)
    var path = [String]()
    while let unwrapped = segment {
      if unwrapped.title != projectNodes.first?.mainGroup {
        path.append(unwrapped.title)
      }
      segment = parentForObject(unwrapped.id)
    }
    return path.reversed().joined(separator:"/")
  }
}

enum ProjectParseError: String, Error {
  case failedToReadProjectFile = "Unable to read the project file from disk."
  case failedToInflateProjectFile = "Unable to convert the project file into a String."
  case failedToSerializeProjectData = "PropertyListSerialization failed."
  case failedToContortDictionary = "Failed to contort NSDictionary into Swift Dictionary."
  case failedToParseProjectStructure = "ProjectParser failed to completely parse the project."
}
