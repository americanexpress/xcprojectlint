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

/// Many things are represented by an `id`, but they have a user-
/// friendly name. This protocol describes the two pieces of data
/// we need to describe errors in a meaningful way.
protocol TitledNode: CustomDebugStringConvertible {
  var id: String { get }
  var title: String { get }
}

struct BuildConfiguration: TitledNode {
  var title: String
  var id: String

  let name: String
  let baseConfigurationReference: String?
  let buildSettings: Dictionary<String, Any>
  var debugDescription: String
  
  init(key: String, value: Dictionary<String, Any>, title: String) {
    identifyUnparsedKeys(value, knownKeys: ["name", "baseConfigurationReference", "buildSettings"])
    self.id = key
    self.title = title
    self.name = value["name"] as? String ?? "Untitled"
    self.baseConfigurationReference = value["baseConfigurationReference"] as? String
    self.buildSettings = value["buildSettings"] as! Dictionary<String, Any>
    
    self.debugDescription = "\(name) (\(key))"
  }
}

struct BuildConfigurationList: TitledNode {
  var title: String
  var id: String
  let buildConfigurations: [String]
  let defaultConfigurationName: String?
  let defaultConfigurationIsVisible: Bool
  var debugDescription: String
  
  init(key: String, value: Dictionary<String, Any>, title: String) {
    identifyUnparsedKeys(value, knownKeys: ["buildConfigurations", "defaultConfigurationName", "defaultConfigurationIsVisible"])
    self.id = key
    self.title = title
    self.buildConfigurations = value["buildConfigurations"] as! [String]
    self.defaultConfigurationName = value["defaultConfigurationName"] as? String
    self.defaultConfigurationIsVisible = (value["defaultConfigurationIsVisible"] as! String) == "1"
    
    self.debugDescription = buildConfigurations.debugDescription
  }
}

struct BuildFile: CustomDebugStringConvertible {
  let key: String
  let fileRef: String
  
  var debugDescription: String
  
  init(key: String, value: Dictionary<String, Any>) {
    identifyUnparsedKeys(value, knownKeys: ["fileRef", "settings"])
    self.key = key
    self.fileRef = value["fileRef"] as! String
    
    self.debugDescription = "\(fileRef) (\(key))"
  }
}

struct ContainerItemProxy: CustomDebugStringConvertible {
  let remoteInfo: String
  let proxyType: String
  let containerPortal: String
  let remoteGlobalIDString: String
  var debugDescription: String
  
  init(value: Dictionary<String, Any>) {
    identifyUnparsedKeys(value, knownKeys: ["remoteInfo", "proxyType", "containerPortal", "remoteGlobalIDString"])
    self.remoteInfo = value["remoteInfo"] as! String
    self.proxyType = value["proxyType"] as! String
    self.containerPortal = value["containerPortal"] as! String
    self.remoteGlobalIDString = value["remoteGlobalIDString"] as! String
    
    self.debugDescription = "undefined"
  }
}

struct CopyFilesBuildPhase: CustomDebugStringConvertible {
  let dstSubfolderSpec: String
  let files: [String]
  let name: String
  let dstPath: String
  let runOnlyForDeploymentPostprocessing: Bool
  let buildActionMask: String
  var debugDescription: String
  
  init(value: Dictionary<String, Any>) {
    identifyUnparsedKeys(value, knownKeys: ["dstSubfolderSpec", "files", "name", "dstPath", "runOnlyForDeploymentPostprocessing", "buildActionMask"])
    self.dstSubfolderSpec = value["dstSubfolderSpec"] as! String
    self.files = value["files"] as! [String]
    self.name = value["name"] as? String ?? "Untitled"
    self.dstPath = value["dstPath"] as! String
    self.runOnlyForDeploymentPostprocessing = (value["runOnlyForDeploymentPostprocessing"] as! String) == "1"
    self.buildActionMask = value["buildActionMask"] as! String
    
    self.debugDescription = self.name
  }
}

struct FileReference: TitledNode {
  let title: String
  let id: String
  let name: String? // presense of a "name" indicates a path that doesn't match the filesystem
  let path: String
  let explicitFileType: String?
  let lastKnownFileType: String?
  let sourceTree: String
  let fileEncoding: String?
  let lineEnding: String?
  let xcLanguageSpecificationIdentifier: String?
  let includeInIndex: Bool?
  var debugDescription: String
  
  init(key: String, value: Dictionary<String, Any>, title: String, projectPath: String) {
    identifyUnparsedKeys(value, knownKeys: ["path", "name", "explicitFileType", "lastKnownFileType", "sourceTree", "fileEncoding", "lineEnding", "xcLanguageSpecificationIdentifier", "includeInIndex"])
    self.title = title
    self.path = value["path"] as! String
    self.name = value["name"] as? String
    self.explicitFileType = value["explicitFileType"] as? String
    self.lastKnownFileType = value["lastKnownFileType"] as? String
    self.sourceTree = value["sourceTree"] as! String
    self.fileEncoding = value["fileEncoding"] as? String
    self.lineEnding = value["lineEnding"] as? String
    self.xcLanguageSpecificationIdentifier = value["xcLanguageSpecificationIdentifier"] as? String
    self.includeInIndex = (value["includeInIndex"] as? String) == "1"
    self.id = key
    
    self.debugDescription = "\(title) (\(id))"
  }
}

struct FrameworksBuildPhase: CustomDebugStringConvertible {
  let files: [String]
  let runOnlyForDeploymentPostprocessing: Bool
  let buildActionMask: String
  var debugDescription: String
  
  init(value: Dictionary<String, Any>) {
    identifyUnparsedKeys(value, knownKeys: ["files", "runOnlyForDeploymentPostprocessing", "buildActionMask"])
    self.files = value["files"] as! [String]
    self.runOnlyForDeploymentPostprocessing = (value["runOnlyForDeploymentPostprocessing"] as! String) == "1"
    self.buildActionMask = value["buildActionMask"] as! String
    
    self.debugDescription = "undefined"
  }
}

struct Group: TitledNode {
  let title: String // extracted from comments
  let id: String
  let name: String?
  let path: String?
  let sourceTree: String
  let children: [String]
  let indentWidth: String?
  let tabWidth: String?
  var debugDescription: String
  
  init(key: String, value: Dictionary<String, Any>, title: String) {
    identifyUnparsedKeys(value, knownKeys: ["name", "path", "sourceTree", "children", "indentWidth", "tabWidth"])
    self.title = title
    self.id = key
    self.name = value["name"] as? String
    self.path = value["path"] as? String
    self.sourceTree = value["sourceTree"] as! String
    self.children = value["children"] as! [String]
    self.indentWidth = value["indentWidth"] as? String
    self.tabWidth = value["tabWidth"] as? String
    
    self.debugDescription = title
  }
}

struct LegacyTarget: CustomDebugStringConvertible {
  let name: String
  let productName: String
  let dependencies: [String]
  let buildArgumentsString: String
  let buildConfigurationList: String
  let buildWorkingDirectory: String
  let passBuildSettingsInEnvironment: Bool
  let buildPhases: [String]
  let buildToolPath: String
  var debugDescription: String
  
  init(value: Dictionary<String, Any>) {
    identifyUnparsedKeys(value, knownKeys: ["name", "productName", "dependencies", "buildArgumentsString", "buildConfigurationList", "buildWorkingDirectory", "passBuildSettingsInEnvironment", "buildPhases", "buildToolPath"])
    self.name = value["name"] as! String
    self.productName = value["productName"] as! String
    self.dependencies = value["dependencies"] as! [String]
    self.buildArgumentsString = value["buildArgumentsString"] as! String
    self.buildConfigurationList = value["buildConfigurationList"] as! String
    self.buildWorkingDirectory = value["buildWorkingDirectory"] as! String
    self.passBuildSettingsInEnvironment = (value["passBuildSettingsInEnvironment"] as! String) == "1"
    self.buildPhases = value["buildPhases"] as! [String]
    self.buildToolPath = value["buildToolPath"] as! String
    
    self.debugDescription = "\(name)\n\(buildConfigurationList)"
  }
}

struct NativeTarget: CustomDebugStringConvertible {
  let name: String
  let productName: String
  let productType: String
  let buildRules: [String]
  let productReference: String
  let dependencies: [String]
  let buildConfigurationList: String
  let buildPhases: [String]
  var debugDescription: String
  
  init(value: Dictionary<String, Any>) {
    identifyUnparsedKeys(value, knownKeys: ["name", "productName", "productType", "buildRules", "productReference", "dependencies", "buildConfigurationList", "buildPhases"])
    self.name = value["name"] as! String
    self.productName = value["productName"] as! String
    self.productType = value["productType"] as! String
    self.buildRules = value["buildRules"] as! [String]
    self.productReference = value["productReference"] as! String
    self.dependencies = value["dependencies"] as! [String]
    self.buildConfigurationList = value["buildConfigurationList"] as! String
    self.buildPhases = value["buildPhases"] as! [String]
    
    self.debugDescription = "\(name)\n\(buildConfigurationList)"
  }
}

struct ProjectNode: CustomDebugStringConvertible {
  let mainGroup: String
  let developmentRegion: String
  let projectDirPath: String
  let productRefGroup: String
  let targets: [String]
  let buildConfigurationList: String
  let knownRegions: [String]
  let compatibilityVersion: String
  let hasScannedForEncodings: Bool
  let projectRoot: String
  
  var debugDescription: String
  
  init(value: Dictionary<String, Any>) {
    identifyUnparsedKeys(value, knownKeys: ["mainGroup", "attributes", "developmentRegion", "projectDirPath", "productRefGroup", "targets", "buildConfigurationList", "knownRegions", "compatibilityVersion", "hasScannedForEncodings", "projectRoot"])
    self.mainGroup = value["mainGroup"] as! String
    self.developmentRegion = value["developmentRegion"] as! String
    self.projectDirPath = value["projectDirPath"] as! String
    self.productRefGroup = value["productRefGroup"] as! String
    self.targets = value["targets"] as! [String]
    self.buildConfigurationList = value["buildConfigurationList"] as! String
    self.knownRegions = value["knownRegions"] as! [String]
    self.compatibilityVersion = value["compatibilityVersion"] as! String
    self.hasScannedForEncodings = (value["hasScannedForEncodings"] as! String) == "1"
    self.projectRoot = value["projectRoot"] as! String
    
    self.debugDescription = "undefined"
  }
}

struct ResourcesBuildPhase: CustomDebugStringConvertible {
  let files: [String]
  let runOnlyForDeploymentPostprocessing: Bool
  let buildActionMask: String
  var debugDescription: String
  
  init(value: Dictionary<String, Any>) {
    identifyUnparsedKeys(value, knownKeys: ["files", "runOnlyForDeploymentPostprocessing", "buildActionMask"])
    self.files = value["files"] as! [String]
    self.runOnlyForDeploymentPostprocessing = (value["runOnlyForDeploymentPostprocessing"] as! String) == "1"
    self.buildActionMask = value["buildActionMask"] as! String
    
    self.debugDescription = files.debugDescription
  }
}

struct ShellScriptBuildPhase: CustomDebugStringConvertible {
  let showEnvVarsInLog: Bool
  let files: [String]
  let name: String
  let runOnlyForDeploymentPostprocessing: Bool
  let shellPath: String
  let inputPaths: [String]
  let outputPaths: [String]
  let shellScript: String
  let buildActionMask: String
  var debugDescription: String
  
  init(value: Dictionary<String, Any>) {
    identifyUnparsedKeys(value, knownKeys: ["showEnvVarsInLog", "files", "name", "runOnlyForDeploymentPostprocessing", "shellPath", "inputPaths", "outputPaths", "shellScript", "buildActionMask"])
    self.showEnvVarsInLog = (value["showEnvVarsInLog"] as? String) == "1"
    self.files = value["files"] as! [String]
    self.name = value["name"] as? String ?? "Untitled"
    self.runOnlyForDeploymentPostprocessing =  (value["runOnlyForDeploymentPostprocessing"] as! String) == "1"
    self.shellPath = value["shellPath"] as! String
    self.inputPaths = value["inputPaths"] as! [String]
    self.outputPaths = value["outputPaths"] as! [String]
    self.shellScript = value["shellScript"] as! String
    self.buildActionMask = value["buildActionMask"] as! String
    
    self.debugDescription = self.name
  }
}

struct SourcesBuildPhase: CustomDebugStringConvertible {
  let files: [String]
  let runOnlyForDeploymentPostprocessing: Bool
  let buildActionMask: String
  var debugDescription: String
  
  init(value: Dictionary<String, Any>) {
    identifyUnparsedKeys(value, knownKeys: ["files", "runOnlyForDeploymentPostprocessing", "buildActionMask"])
    self.files = value["files"] as! [String]
    self.runOnlyForDeploymentPostprocessing = (value["runOnlyForDeploymentPostprocessing"] as! String) == "1"
    self.buildActionMask = value["buildActionMask"] as! String
    
    self.debugDescription = "undefined"
  }
}

struct TargetDependency: CustomDebugStringConvertible {
  let target: String
  let targetProxy: String
  var debugDescription: String
  
  init(value: Dictionary<String, Any>) {
    identifyUnparsedKeys(value, knownKeys: ["target", "targetProxy"])
    self.target = value["target"] as! String
    self.targetProxy = value["targetProxy"] as! String
    
    self.debugDescription = "undefined"
  }
}

struct VariantGroup: CustomDebugStringConvertible {
  let name: String?
  let path: String?
  let sourceTree: String
  let children: [String]
  
  var debugDescription: String
  
  init(value: Dictionary<String, Any>) {
    identifyUnparsedKeys(value, knownKeys: ["name", "path", "sourceTree", "children"])
    self.name = value["name"] as? String
    self.path = value["path"] as? String
    self.sourceTree = value["sourceTree"] as! String
    self.children = value["children"] as! [String]
    
    self.debugDescription = "undefined"
  }
}

/// Go through a XCConfiguration section, and build a map of
/// ids to build configurations
func extractBuildConfigurationTitles(_ projectText: String) -> Dictionary<String, String> {
  var titleMap = Dictionary<String, String>()
  var inBuildConfigsSection = false
  projectText.enumerateLines(invoking: { (line, stop) in
    if !inBuildConfigsSection {
      if line.contains("XCBuildConfiguration section") {
        inBuildConfigsSection = true
      }
      return
    }
    
    // see if we're done
    if line.contains("XCBuildConfiguration section") {
      stop = true
      return
    }
    // we're in the build section, and not done, so pull apart the line
    var line = line.trimmingCharacters(in: .whitespaces)
    
    var splits = line.components(separatedBy: " /* ")
    if splits.count != 2 {
      return
    }
    let key = splits[0]
    line = splits[1]
    splits = line.components(separatedBy: " */")
    if splits.count != 2 { return }
    let title = splits[0]
    titleMap[key] = title
  })
  
  return titleMap
}

/// Go through a XCConfigurationList section, and build a map of
/// ids to build configuration lists
func extractBuildConfigurationListTitles(_ projectText: String) -> Dictionary<String, String> {
  var titleMap = Dictionary<String, String>()
  var inBuildConfigsSection = false
  projectText.enumerateLines(invoking: { (line, stop) in
    if !inBuildConfigsSection {
      if line.contains("XCConfigurationList section") {
        inBuildConfigsSection = true
      }
      return
    }
    
    // see if we're done
    if line.contains("XCConfigurationList section") {
      stop = true
      return
    }
    // we're in the build section, and not done, so pull apart the line
    var line = line.trimmingCharacters(in: .whitespaces)
    
    var splits = line.components(separatedBy: " /* ")
    if splits.count != 2 {
      return
    }
    let key = splits[0]
    line = splits[1]
    splits = line.components(separatedBy: " */")
    if splits.count != 2 { return }
    let title = splits[0]
    titleMap[key] = title
  })
  
  return titleMap
}

/// Go through a PBXGroup section, and build a map of
/// ids to folder names (as displayed in the Xcode UI)
func extractGroupTitles(_ projectText: String) -> Dictionary<String, String> {
  var titleMap = Dictionary<String, String>()
  var inGroupSection = false
  projectText.enumerateLines(invoking: { (line, stop) in
    if !inGroupSection {
      if line.contains("PBXGroup section") {
        inGroupSection = true
      }
      return
    }
    
    // see if we're done
    if line.contains("PBXGroup section") {
      stop = true
      return
    }
    // we're in the build section, and not done, so pull apart the line
    var line = line.trimmingCharacters(in: .whitespaces)
    
    var splits = line.components(separatedBy: " /* ")
    if splits.count != 2 {
      return
    }
    let key = splits[0]
    line = splits[1]
    splits = line.components(separatedBy: " */")
    if splits.count != 2 { return }
    let title = splits[0]
    titleMap[key] = title
  })
  
  return titleMap
}

/// Go through a PBXFileReference section, and build a map of
/// ids to file names (as displayed in the Xcode UI)
func extractFileTitles(_ projectText: String) -> Dictionary<String, String> {
  var titleMap = Dictionary<String, String>()
  var inFileSection = false
  projectText.enumerateLines(invoking: { (line, stop) in
    if !inFileSection {
      if line.contains("PBXFileReference section") {
        inFileSection = true
      }
      return
    }
    
    // see if we're done
    if line.contains("PBXFileReference section") {
      stop = true
      return
    }
    // we're in the build section, and not done, so pull apart the line
    var line = line.trimmingCharacters(in: .whitespaces)
    var splits = line.components(separatedBy: " */")
    if splits.count != 2 { return }
    line = splits[0]
    splits = line.components(separatedBy: " /* ")
    if splits.count != 2 { return }
    line = splits[0]
    let title = splits[1]
    splits = line.components(separatedBy: " = ")
    if splits.count != 1 { return }
    let key = splits[0]
    titleMap[key] = title
  })
  
  return titleMap
}

/// Many things are tracked by an identifier. We've extracted names for
/// many of those things, usually by sniffing comments.
/// - parameters:
///   - key: The id we’re about to display
///   - titles: A dictionary of the titles in this scope
/// - returns: The display name for that `id`, or the `id` if it cannot be found
func title(_ key: String, titles: Dictionary<String, String>) -> String {
  return titles[key] ?? key
}

/// Since we built this parser through observation, catch cases where
/// we find keys previously unknown. This is an unfortunately manual
/// process, where we have every`init()` call us. It’s OK to _not_
/// see a key, but finding one we’ve never seen is probably an error.
/// - parameters:
///   - values: The node being parsed
///   - knownKeys: A list of every key we’ve ever seen in this kind of node
func identifyUnparsedKeys(_ values: Dictionary<String, Any>, knownKeys: [String]) {

  for (key, _) in values {
    guard key != "isa" else { continue }
    if !knownKeys.contains(key) {
      print("\(key)")
    }
  }
}

/// This class turns a pbxproj file into a bunch of Collections
/// we can later traverse to determine if the project is arranged according
/// to our preferences.
///
/// The format of an Xcode project file is not documented, so this parser
/// is built entirely on good intentions, and observed behavior. Some of the
/// relationships are self-apparent, but others rely on our interpretation
/// of comments Xcode kindly leaves lying about.
///
/// We start this mess off by grabbing the `objects` node out of the top
/// level dictiopnary. It contains pretty much everything interesting.
///
class ProjectParser {
  private let objects: [String: Any]
  private let rootObject: String
  private let projectPath: String
  
  var buildConfigurationLists = Dictionary<String, BuildConfigurationList>()
  var buildConfigurations = [BuildConfiguration]()
  var buildFiles = Dictionary<String, BuildFile>()
  var containerItemProxies = [ContainerItemProxy]()
  var copyFilesPhases = [CopyFilesBuildPhase]()
  var fileReferences = Dictionary<String, FileReference>()
  var frameworksBuildPhases = [FrameworksBuildPhase]()
  var groups = Dictionary<String, Group>()
  var legacyTargets = [LegacyTarget]()
  var nativeTargets = [NativeTarget]()
  var projectNodes = [ProjectNode]()
  var resourceBuildPhases = [ResourcesBuildPhase]()
  var shellScriptBuildPhases = [ShellScriptBuildPhase]()
  var sourcesBuildPhases = [SourcesBuildPhase]()
  var targetDependencies = [TargetDependency]()
  var titles = Dictionary<String, String>()
  var variantGroups = [VariantGroup]()
  
  /// - parameters:
  ///   - project: The pbxproj file, loaded into a Dictionary
  ///   - projectText: Raw text of the pbxproj file
  ///   - projectPath: Path to the `xcodeproj` container
  /// - returns: A ProjectParser, populated with details, but
  /// no relationships
init(project: Dictionary<String, Any>, projectText: String, projectPath: String) {
    self.objects = project["objects"] as! [String: Any]
    self.rootObject = project["rootObject"] as! String
    titles = extractFileTitles(projectText)
    for (key, value) in extractGroupTitles(projectText) {
      titles[key] = value
    }
    for (key, value) in extractBuildConfigurationTitles(projectText) {
      titles[key] = value
    }
    for (key, value) in extractBuildConfigurationListTitles(projectText) {
      titles[key] = value
    }

    self.projectPath = projectPath
  }
  
  /// Brute force walk through the top-level key:value pairs, and
  /// call the specialized parser for each node type.
  ///
  /// This switch statement represents our current understanding of
  /// the kinds of data a project file represents.
  func parse() -> Bool {
    var parsed = false
    for (key, value) in objects {
      if let node = value as? Dictionary<String, Any> {
        switch node["isa"] as! String {
        case "PBXBuildFile":
          let file = BuildFile(key: key, value: node)
          buildFiles[key] = file
        case "PBXFileReference":
          let file = FileReference(key: key, value: node, title: title(key, titles: titles), projectPath: projectPath)
          fileReferences[key] = file
        case "PBXLegacyTarget":
          let target = LegacyTarget(value: node)
          legacyTargets.append(target)
        case "PBXNativeTarget":
          let target = NativeTarget(value: node)
          nativeTargets.append(target)
        case "PBXResourcesBuildPhase":
          let phase = ResourcesBuildPhase(value: node)
          resourceBuildPhases.append(phase)
        case "XCConfigurationList":
          let configurationList = BuildConfigurationList(key: key, value: node, title: title(key, titles: titles))
          buildConfigurationLists[key] = configurationList
        case "XCBuildConfiguration":
          let buildConfiguration = BuildConfiguration(key: key, value: node, title: title(key, titles: titles))
          buildConfigurations.append(buildConfiguration)
        case "PBXGroup":
          let group = Group(key: key, value: node, title: title(key, titles: titles))
          groups[key] = group
        case "PBXContainerItemProxy":
          let containerItemProxy = ContainerItemProxy(value: node)
          containerItemProxies.append(containerItemProxy)
        case "PBXProject":
          let project = ProjectNode(value: node)
          projectNodes.append(project)
        case "PBXFrameworksBuildPhase":
          let buildPhase = FrameworksBuildPhase(value: node)
          frameworksBuildPhases.append(buildPhase)
        case "PBXShellScriptBuildPhase":
          let buildPhase = ShellScriptBuildPhase(value: node)
          shellScriptBuildPhases.append(buildPhase)
        case "PBXSourcesBuildPhase":
          let buildPhase = SourcesBuildPhase(value: node)
          sourcesBuildPhases.append(buildPhase)
        case "PBXTargetDependency":
          let targetDependency = TargetDependency(value: node)
          targetDependencies.append(targetDependency)
        case "PBXVariantGroup":
          let variantGroup = VariantGroup(value: node)
          variantGroups.append(variantGroup)
        case "PBXCopyFilesBuildPhase":
          let buildPhase = CopyFilesBuildPhase(value: node)
          copyFilesPhases.append(buildPhase)
        case "PBXHeadersBuildPhase":
          break
        default:
          print("New type found: \(node)")
        }
      }
      parsed = true
    }
    return parsed
  }
}
