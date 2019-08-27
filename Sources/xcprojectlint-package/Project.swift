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
  public let projectName: String
  public let url: URL
  public let projectText: String

  public let buildConfigurationLists: [String: BuildConfigurationList]
  public let buildConfigurations: [BuildConfiguration]
  public let buildFiles: [String: BuildFile]
  public let containerItemProxies: [ContainerItemProxy]
  public let copyFilesPhases: [CopyFilesBuildPhase]
  public let fileReferences: [String: FileReference]
  public let frameworksBuildPhases: [FrameworksBuildPhase]
  public let groups: [String: Group]
  public let legacyTargets: [LegacyTarget]
  public let nativeTargets: [NativeTarget]
  public let projectNodes: [ProjectNode]
  public let resourceBuildPhases: [ResourcesBuildPhase]
  public let shellScriptBuildPhases: [ShellScriptBuildPhase]
  public let sourcesBuildPhases: [SourcesBuildPhase]
  public let targetDependencies: [TargetDependency]
  public let titles: [String: String]
  public let variantGroups: [VariantGroup]

  public init(_ projectPath: String, errorReporter _: ErrorReporter) throws {
    let filename = "project.pbxproj"
    let projectURL = URL(fileURLWithPath: projectPath)
    let url = projectURL.appendingPathComponent(filename)

    guard let data = try? Data(contentsOf: url) else { throw ProjectParseError.failedToReadProjectFile }
    guard let projectText = String(data: data, encoding: .utf8) else { throw ProjectParseError.failedToInflateProjectFile }
    guard let serialization = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [AnyHashable: Any] else { throw ProjectParseError.failedToSerializeProjectData }
    guard let plist = serialization else { throw ProjectParseError.failedToSerializeProjectData }
    guard let dict = plist as? [String: Any] else { throw ProjectParseError.failedToContortDictionary }

    let parser = ProjectParser(project: dict, projectText: projectText, projectPath: projectPath)
    guard parser.parse() else { throw ProjectParseError.failedToParseProjectStructure }

    projectName = projectURL.lastPathComponent
    self.url = url
    self.projectText = projectText

    buildConfigurationLists = parser.buildConfigurationLists
    buildConfigurations = parser.buildConfigurations
    buildFiles = parser.buildFiles
    containerItemProxies = parser.containerItemProxies
    copyFilesPhases = parser.copyFilesPhases
    fileReferences = parser.fileReferences
    frameworksBuildPhases = parser.frameworksBuildPhases
    groups = parser.groups
    legacyTargets = parser.legacyTargets
    nativeTargets = parser.nativeTargets
    projectNodes = parser.projectNodes
    resourceBuildPhases = parser.resourceBuildPhases
    shellScriptBuildPhases = parser.shellScriptBuildPhases
    sourcesBuildPhases = parser.sourcesBuildPhases
    targetDependencies = parser.targetDependencies
    titles = parser.titles
    variantGroups = parser.variantGroups
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
    return path.reversed().joined(separator: "/")
  }
}

enum ProjectParseError: String, Error {
  case failedToReadProjectFile = "Unable to read the project file from disk."
  case failedToInflateProjectFile = "Unable to convert the project file into a String."
  case failedToSerializeProjectData = "PropertyListSerialization failed."
  case failedToContortDictionary = "Failed to contort NSDictionary into Swift Dictionary."
  case failedToParseProjectStructure = "ProjectParser failed to completely parse the project."
}
