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

public protocol Identifiable {
  var id: String { get }
}

/// Many things are represented by an `id`, but they have a user-
/// friendly name. This protocol describes the two pieces of data
/// we need to describe errors in a meaningful way.
public protocol TitledNode: Identifiable, CustomDebugStringConvertible {
  var title: String { get }
}

// Many nodes contain lists of files.
// This protocol generilizes them.
public protocol FileContainer {
  var files: [String] { get }
}

/// There are fields we expect to always be present, but we've just
/// discovered, `swift package generate-xcodeproj` projects are missing
/// at least one of them. Instead of playing whack-a-mole finding them,
/// here’s a helper that A: doesn’t crash; b: asks for a bug report.

extension Dictionary where Key == String {
  func string(forKey key: String, container: String) -> String {
    if let value = self[key] as? String {
      return value
    }

    ErrorReporter.report("We didn’t find an expected key (\(key)) in “\(container)”. Please open a bug report at https://github.com/americanexpress/xcprojectlint/issues so we can investigate.\n")

    return "Unavailable"
  }
}

public struct BuildConfiguration: TitledNode {
  public let title: String
  public let id: String
  public let debugDescription: String

  public let name: String
  public let baseConfigurationReference: String?
  public let buildSettings: [String: Any]

  init(key: String, value: [String: Any], title: String) {
    identifyUnparsedKeys(value, knownKeys: ["name", "baseConfigurationReference", "buildSettings"])
    id = key
    self.title = title
    name = value["name"] as? String ?? "Untitled"
    baseConfigurationReference = value["baseConfigurationReference"] as? String
    buildSettings = value["buildSettings"] as! [String: Any]

    debugDescription = "\(name) (\(key))"
  }
}

public struct BuildConfigurationList: TitledNode {
  public let title: String
  public let id: String
  public let debugDescription: String
  public let buildConfigurations: [String]
  public let defaultConfigurationName: String?
  public let defaultConfigurationIsVisible: Bool

  init(key: String, value: [String: Any], title: String) {
    identifyUnparsedKeys(value, knownKeys: ["buildConfigurations", "defaultConfigurationName", "defaultConfigurationIsVisible"])
    id = key
    self.title = title
    buildConfigurations = value["buildConfigurations"] as! [String]
    defaultConfigurationName = value["defaultConfigurationName"] as? String
    defaultConfigurationIsVisible = value.string(forKey: "defaultConfigurationIsVisible", container: "\(type(of: self))") == "1"

    debugDescription = buildConfigurations.debugDescription
  }
}

public struct BuildFile: Identifiable, CustomDebugStringConvertible {
  public let id: String
  public let key: String
  public let fileRef: String?
  public let productRef: String?
  public let debugDescription: String

  init(key: String, value: [String: Any]) {
    identifyUnparsedKeys(value, knownKeys: ["fileRef", "productRef", "settings"])
    id = key
    self.key = key
    fileRef = value["fileRef"] as? String
    productRef = value["productRef"] as? String

    debugDescription = "\(fileRef != nil ? "fileRef" : "productRef") (\(key))"
  }
}

public struct ContainerItemProxy: Identifiable, CustomDebugStringConvertible {
  public let id: String
  public let debugDescription: String
  public let remoteInfo: String
  public let proxyType: String
  public let containerPortal: String
  public let remoteGlobalIDString: String

  init(key: String, value: [String: Any]) {
    identifyUnparsedKeys(value, knownKeys: ["remoteInfo", "proxyType", "containerPortal", "remoteGlobalIDString"])
    id = key
    remoteInfo = value.string(forKey: "remoteInfo", container: "\(type(of: self))")
    proxyType = value.string(forKey: "proxyType", container: "\(type(of: self))")
    containerPortal = value.string(forKey: "containerPortal", container: "\(type(of: self))")
    remoteGlobalIDString = value.string(forKey: "remoteGlobalIDString", container: "\(type(of: self))")

    debugDescription = "undefined"
  }
}

public struct CopyFilesBuildPhase: Identifiable, FileContainer, CustomDebugStringConvertible {
  public let id: String
  public let files: [String]
  public let name: String
  public let debugDescription: String
  public let dstSubfolderSpec: String
  public let dstPath: String
  public let runOnlyForDeploymentPostprocessing: Bool
  public let buildActionMask: String

  init(key: String, value: [String: Any]) {
    identifyUnparsedKeys(value, knownKeys: ["dstSubfolderSpec", "files", "name", "dstPath", "runOnlyForDeploymentPostprocessing", "buildActionMask"])
    dstSubfolderSpec = value.string(forKey: "dstSubfolderSpec", container: "\(type(of: self))")
    id = key
    files = value["files"] as! [String]
    name = value["name"] as? String ?? "Untitled"
    dstPath = value.string(forKey: "dstPath", container: "\(type(of: self))")
    runOnlyForDeploymentPostprocessing = value.string(forKey: "runOnlyForDeploymentPostprocessing", container: "\(type(of: self))") == "1"
    buildActionMask = value.string(forKey: "buildActionMask", container: "\(type(of: self))")

    debugDescription = name
  }
}

public struct FileReference: TitledNode {
  public let title: String
  public let id: String
  public let name: String? // presence of a "name" indicates a path that doesn't match the filesystem
  public let path: String
  public let explicitFileType: String?
  public let lastKnownFileType: String?
  public let sourceTree: String
  public let fileEncoding: String?
  public let lineEnding: String?
  public let xcLanguageSpecificationIdentifier: String?
  public let includeInIndex: Bool?
  public let debugDescription: String
  public let indentWidth: String?
  public let tabWidth: String?
  public let wrapsLines: String?

  init(key: String, value: [String: Any], title: String, projectPath _: String) {
    identifyUnparsedKeys(value, knownKeys: ["explicitFileType", "fileEncoding", "includeInIndex", "indentWidth", "lastKnownFileType", "lineEnding", "name", "path", "sourceTree", "tabWidth", "wrapsLines", "xcLanguageSpecificationIdentifier"])
    self.title = title
    id = key
    path = value.string(forKey: "path", container: "\(type(of: self))")
    name = value["name"] as? String
    explicitFileType = value["explicitFileType"] as? String
    lastKnownFileType = value["lastKnownFileType"] as? String
    sourceTree = value.string(forKey: "sourceTree", container: "\(type(of: self))")
    fileEncoding = value["fileEncoding"] as? String
    lineEnding = value["lineEnding"] as? String
    xcLanguageSpecificationIdentifier = value["xcLanguageSpecificationIdentifier"] as? String
    includeInIndex = (value["includeInIndex"] as? String) == "1"
    indentWidth = value["indentWidth"] as? String
    tabWidth = value["tabWidth"] as? String
    wrapsLines = value["wrapsLines"] as? String

    debugDescription = "\(title) (\(id))"
  }
}

public struct FrameworksBuildPhase: Identifiable, FileContainer, CustomDebugStringConvertible {
  public let id: String
  public let files: [String]
  public let debugDescription: String
  public let runOnlyForDeploymentPostprocessing: Bool
  public let buildActionMask: String

  init(key: String, value: [String: Any]) {
    identifyUnparsedKeys(value, knownKeys: ["files", "runOnlyForDeploymentPostprocessing", "buildActionMask"])
    id = key
    files = value["files"] as! [String]
    runOnlyForDeploymentPostprocessing = value.string(forKey: "runOnlyForDeploymentPostprocessing", container: "\(type(of: self))") == "1"
    buildActionMask = value.string(forKey: "buildActionMask", container: "\(type(of: self))")

    debugDescription = "undefined"
  }
}

public struct Group: TitledNode {
  public let title: String // extracted from comments
  public let id: String
  public let debugDescription: String
  public let name: String?
  public let path: String?
  public let sourceTree: String
  public let children: [String]
  public let indentWidth: String?
  public let tabWidth: String?
  public let usesTabs: String?
  public let wrapsLines: String?

  init(key: String, value: [String: Any], title: String) {
    identifyUnparsedKeys(value, knownKeys: ["children", "indentWidth", "name", "path", "sourceTree", "tabWidth", "usesTabs", "wrapsLines"])
    self.title = title
    id = key
    name = value["name"] as? String
    path = value["path"] as? String
    sourceTree = value.string(forKey: "sourceTree", container: "\(type(of: self))")
    children = value["children"] as! [String]
    indentWidth = value["indentWidth"] as? String
    tabWidth = value["tabWidth"] as? String
    usesTabs = value["usesTabs"] as? String
    wrapsLines = value["wrapsLines"] as? String

    debugDescription = title
  }
}

public struct LegacyTarget: Identifiable, CustomDebugStringConvertible {
  public let id: String
  public let debugDescription: String
  public let name: String
  public let productName: String
  public let dependencies: [String]
  public let buildArgumentsString: String
  public let buildConfigurationList: String
  public let buildWorkingDirectory: String
  public let passBuildSettingsInEnvironment: Bool
  public let buildPhases: [String]
  public let buildToolPath: String

  init(key: String, value: [String: Any]) {
    identifyUnparsedKeys(value, knownKeys: ["name", "productName", "dependencies", "buildArgumentsString", "buildConfigurationList", "buildWorkingDirectory", "passBuildSettingsInEnvironment", "buildPhases", "buildToolPath"])
    id = key
    name = value.string(forKey: "name", container: "\(type(of: self))")
    productName = value.string(forKey: "productName", container: "\(type(of: self))")
    dependencies = value["dependencies"] as! [String]
    buildArgumentsString = value.string(forKey: "buildArgumentsString", container: "\(type(of: self))")
    buildConfigurationList = value.string(forKey: "buildConfigurationList", container: "\(type(of: self))")
    buildWorkingDirectory = value.string(forKey: "buildWorkingDirectory", container: "\(type(of: self))")
    passBuildSettingsInEnvironment = value.string(forKey: "passBuildSettingsInEnvironment", container: "\(type(of: self))") == "1"
    buildPhases = value["buildPhases"] as! [String]
    buildToolPath = value.string(forKey: "buildToolPath", container: "\(type(of: self))")

    debugDescription = "\(name)\n\(buildConfigurationList)"
  }
}

public struct NativeTarget: Identifiable, CustomDebugStringConvertible {
  public let id: String
  public let name: String
  public let buildPhases: [String]
  public let debugDescription: String
  public let productName: String
  public let productType: String
  public let buildRules: [String]
  public let productReference: String
  public let dependencies: [String]
  public let buildConfigurationList: String

  init(key: String, value: [String: Any]) {
    identifyUnparsedKeys(value, knownKeys: ["buildConfigurationList", "buildPhases", "buildRules", "dependencies", "name", "packageProductDependencies", "packageReferences", "productName", "productRef", "productReference", "productType"])
    id = key
    name = value.string(forKey: "name", container: "\(type(of: self))")
    productName = value.string(forKey: "productName", container: "\(type(of: self))")
    productType = value.string(forKey: "productType", container: "\(type(of: self))")
    buildRules = value["buildRules"] as! [String]
    productReference = value["productReference"] as? String ?? "Not Found"
    dependencies = value["dependencies"] as! [String]
    buildConfigurationList = value.string(forKey: "buildConfigurationList", container: "\(type(of: self))")
    buildPhases = value["buildPhases"] as! [String]

    debugDescription = "\(name)\n\(buildConfigurationList)"
  }
}

public struct ProjectNode: Identifiable, CustomDebugStringConvertible {
  public let id: String
  public let debugDescription: String
  public let mainGroup: String
  public let developmentRegion: String
  public let projectDirPath: String
  public let productRefGroup: String
  public let targets: [String]
  public let buildConfigurationList: String
  public let knownRegions: [String]
  public let compatibilityVersion: String
  public let hasScannedForEncodings: Bool
  public let projectRoot: String

  init(key: String, value: [String: Any]) {
    identifyUnparsedKeys(value, knownKeys: ["attributes", "buildConfigurationList", "compatibilityVersion", "developmentRegion", "hasScannedForEncodings", "knownRegions", "mainGroup", "packageReferences", "productRefGroup", "projectDirPath", "projectRoot", "targets"])
    id = key
    mainGroup = value.string(forKey: "mainGroup", container: "\(type(of: self))")
    developmentRegion = value.string(forKey: "developmentRegion", container: "\(type(of: self))")
    projectDirPath = value.string(forKey: "projectDirPath", container: "\(type(of: self))")
    productRefGroup = value.string(forKey: "productRefGroup", container: "\(type(of: self))")
    targets = value["targets"] as! [String]
    buildConfigurationList = value.string(forKey: "buildConfigurationList", container: "\(type(of: self))")
    knownRegions = value["knownRegions"] as! [String]
    compatibilityVersion = value.string(forKey: "compatibilityVersion", container: "\(type(of: self))")
    hasScannedForEncodings = value.string(forKey: "hasScannedForEncodings", container: "\(type(of: self))") == "1"
    projectRoot = value.string(forKey: "projectRoot", container: "\(type(of: self))")

    debugDescription = "undefined"
  }
}

public struct ResourcesBuildPhase: Identifiable, FileContainer, CustomDebugStringConvertible {
  public let id: String
  public let files: [String]
  public let debugDescription: String
  public let runOnlyForDeploymentPostprocessing: Bool
  public let buildActionMask: String

  init(key: String, value: [String: Any]) {
    identifyUnparsedKeys(value, knownKeys: ["files", "runOnlyForDeploymentPostprocessing", "buildActionMask"])
    id = key
    files = value["files"] as! [String]
    runOnlyForDeploymentPostprocessing = value.string(forKey: "runOnlyForDeploymentPostprocessing", container: "\(type(of: self))") == "1"
    buildActionMask = value.string(forKey: "buildActionMask", container: "\(type(of: self))")

    debugDescription = files.debugDescription
  }
}

public struct ShellScriptBuildPhase: Identifiable, FileContainer, CustomDebugStringConvertible {
  public let id: String
  public let files: [String]
  public let debugDescription: String
  public let showEnvVarsInLog: Bool
  public let name: String
  public let runOnlyForDeploymentPostprocessing: Bool
  public let shellPath: String
  public let inputPaths: [String]
  public let outputPaths: [String]
  public let shellScript: String
  public let buildActionMask: String

  init(key: String, value: [String: Any]) {
    identifyUnparsedKeys(value, knownKeys: ["showEnvVarsInLog", "files", "name", "runOnlyForDeploymentPostprocessing", "shellPath", "inputPaths", "outputPaths", "shellScript", "buildActionMask", "inputFileListPaths", "outputFileListPaths"])
    id = key
    showEnvVarsInLog = (value["showEnvVarsInLog"] as? String) == "1"
    files = value["files"] as! [String]
    name = value["name"] as? String ?? "Untitled"
    runOnlyForDeploymentPostprocessing = value.string(forKey: "runOnlyForDeploymentPostprocessing", container: "\(type(of: self))") == "1"
    shellPath = value.string(forKey: "shellPath", container: "\(type(of: self))")
    inputPaths = value["inputPaths"] as? [String] ?? []
    outputPaths = value["outputPaths"] as? [String] ?? []
    shellScript = value.string(forKey: "shellScript", container: "\(type(of: self))")
    buildActionMask = value.string(forKey: "buildActionMask", container: "\(type(of: self))")

    debugDescription = name
  }
}

public struct SourcesBuildPhase: Identifiable, FileContainer, CustomDebugStringConvertible {
  public let id: String
  public let files: [String]
  public let runOnlyForDeploymentPostprocessing: Bool
  public let buildActionMask: String
  public let debugDescription: String

  init(key: String, value: [String: Any]) {
    identifyUnparsedKeys(value, knownKeys: ["files", "runOnlyForDeploymentPostprocessing", "buildActionMask"])
    id = key
    files = value["files"] as! [String]
    runOnlyForDeploymentPostprocessing = value.string(forKey: "runOnlyForDeploymentPostprocessing", container: "\(type(of: self))") == "1"
    buildActionMask = value.string(forKey: "buildActionMask", container: "\(type(of: self))")

    debugDescription = "undefined"
  }
}

public struct TargetDependency: Identifiable, CustomDebugStringConvertible {
  public let id: String
  public let debugDescription: String
  public let target: String
  public let targetProxy: String

  init(key: String, value: [String: Any]) {
    identifyUnparsedKeys(value, knownKeys: ["target", "targetProxy"])
    id = key
    target = value.string(forKey: "target", container: "\(type(of: self))")
    targetProxy = value.string(forKey: "targetProxy", container: "\(type(of: self))")

    debugDescription = "undefined"
  }
}

public struct VariantGroup: Identifiable, CustomDebugStringConvertible {
  public let id: String
  public let debugDescription: String
  public let name: String?
  public let path: String?
  public let sourceTree: String
  public let children: [String]

  init(key: String, value: [String: Any]) {
    identifyUnparsedKeys(value, knownKeys: ["name", "path", "sourceTree", "children"])
    id = key
    name = value["name"] as? String
    path = value["path"] as? String
    sourceTree = value.string(forKey: "sourceTree", container: "\(type(of: self))")
    children = value["children"] as! [String]

    debugDescription = "undefined"
  }
}

/// Go through a XCConfiguration section, and build a map of
/// ids to build configurations
func extractBuildConfigurationTitles(_ projectText: String) -> [String: String] {
  var titleMap = [String: String]()
  var inBuildConfigsSection = false
  for line in projectText.components(separatedBy: CharacterSet.newlines) {
    if !inBuildConfigsSection {
      if line.contains("XCBuildConfiguration section") {
        inBuildConfigsSection = true
      }
      continue
    }

    // see if we're done
    if line.contains("XCBuildConfiguration section") {
      break
    }
    // we're in the build section, and not done, so pull apart the line
    var line = line.trimmingCharacters(in: .whitespaces)

    var splits = line.components(separatedBy: " /* ")
    if splits.count != 2 {
      continue
    }
    let key = splits[0]
    line = splits[1]
    splits = line.components(separatedBy: " */")
    if splits.count != 2 { continue }
    let title = splits[0]
    titleMap[key] = title
  }

  return titleMap
}

/// Go through a XCConfigurationList section, and build a map of
/// ids to build configuration lists
func extractBuildConfigurationListTitles(_ projectText: String) -> [String: String] {
  var titleMap = [String: String]()
  var inBuildConfigsSection = false
  for line in projectText.components(separatedBy: CharacterSet.newlines) {
    if !inBuildConfigsSection {
      if line.contains("XCConfigurationList section") {
        inBuildConfigsSection = true
      }
      continue
    }

    // see if we're done
    if line.contains("XCConfigurationList section") {
      break
    }
    // we're in the build section, and not done, so pull apart the line
    var line = line.trimmingCharacters(in: .whitespaces)

    var splits = line.components(separatedBy: " /* ")
    if splits.count != 2 {
      continue
    }
    let key = splits[0]
    line = splits[1]
    splits = line.components(separatedBy: " */")
    if splits.count != 2 { continue }
    let title = splits[0]
    titleMap[key] = title
  }

  return titleMap
}

/// Go through a PBXGroup section, and build a map of
/// ids to folder names (as displayed in the Xcode UI)
func extractGroupTitles(_ projectText: String) -> [String: String] {
  var titleMap = [String: String]()
  var inGroupSection = false
  for line in projectText.components(separatedBy: CharacterSet.newlines) {
    if !inGroupSection {
      if line.contains("PBXGroup section") {
        inGroupSection = true
      }
      continue
    }

    // see if we're done
    if line.contains("PBXGroup section") {
      break
    }
    // we're in the build section, and not done, so pull apart the line
    var line = line.trimmingCharacters(in: .whitespaces)

    var splits = line.components(separatedBy: " /* ")
    if splits.count != 2 {
      continue
    }
    let key = splits[0]
    line = splits[1]
    splits = line.components(separatedBy: " */")
    if splits.count != 2 { continue }
    let title = splits[0]
    titleMap[key] = title
  }

  return titleMap
}

/// Go through a PBXFileReference section, and build a map of
/// ids to file names (as displayed in the Xcode UI)
func extractFileTitles(_ projectText: String) -> [String: String] {
  var titleMap = [String: String]()
  var inFileSection = false
  for line in projectText.components(separatedBy: CharacterSet.newlines) {
    if !inFileSection {
      if line.contains("PBXFileReference section") {
        inFileSection = true
      }
      continue
    }

    // see if we're done
    if line.contains("PBXFileReference section") {
      break
    }
    // we're in the build section, and not done, so pull apart the line
    var line = line.trimmingCharacters(in: .whitespaces)
    var splits = line.components(separatedBy: " */")
    if splits.count != 2 { continue }
    line = splits[0]
    splits = line.components(separatedBy: " /* ")
    if splits.count != 2 { continue }
    line = splits[0]
    let title = splits[1]
    splits = line.components(separatedBy: " = ")
    if splits.count != 1 { continue }
    let key = splits[0]
    titleMap[key] = title
  }

  return titleMap
}

/// Many things are tracked by an identifier. We've extracted names for
/// many of those things, usually by sniffing comments.
/// - parameters:
///   - key: The id we’re about to display
///   - titles: A dictionary of the titles in this scope
/// - returns: The display name for that `id`, or the `id` if it cannot be found
func title(_ key: String, titles: [String: String]) -> String {
  return titles[key] ?? key
}

/// Since we built this parser through observation, catch cases where
/// we find keys previously unknown. This is an unfortunately manual
/// process, where we have every`init()` call us. It’s OK to _not_
/// see a key, but finding one we’ve never seen is probably an error.
/// - parameters:
///   - values: The node being parsed
///   - knownKeys: A list of every key we’ve ever seen in this kind of node
func identifyUnparsedKeys(_ values: [String: Any], knownKeys: [String]) {
  for (key, _) in values {
    guard key != "isa" else { continue }
    if !knownKeys.contains(key) {
      print("New key found: \(key)")
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
public class ProjectParser {
  private let objects: [String: Any]
  private let rootObject: String
  private let projectPath: String

  var buildConfigurationLists = [String: BuildConfigurationList]()
  var buildConfigurations = [BuildConfiguration]()
  var buildFiles = [String: BuildFile]()
  var containerItemProxies = [ContainerItemProxy]()
  var copyFilesPhases = [CopyFilesBuildPhase]()
  var fileReferences = [String: FileReference]()
  var frameworksBuildPhases = [FrameworksBuildPhase]()
  var groups = [String: Group]()
  var legacyTargets = [LegacyTarget]()
  var nativeTargets = [NativeTarget]()
  var projectNodes = [ProjectNode]()
  var resourceBuildPhases = [ResourcesBuildPhase]()
  var shellScriptBuildPhases = [ShellScriptBuildPhase]()
  var sourcesBuildPhases = [SourcesBuildPhase]()
  var targetDependencies = [TargetDependency]()
  var titles = [String: String]()
  var variantGroups = [VariantGroup]()

  /// - parameters:
  ///   - project: The pbxproj file, loaded into a Dictionary
  ///   - projectText: Raw text of the pbxproj file
  ///   - projectPath: Path to the `xcodeproj` container
  /// - returns: A ProjectParser, populated with details, but
  /// no relationships
  init(project: [String: Any], projectText: String, projectPath: String) {
    objects = project["objects"] as! [String: Any]
    rootObject = project["rootObject"] as! String
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
      if let node = value as? [String: Any] {
        switch node["isa"] as! String {
        case "PBXBuildFile":
          let file = BuildFile(key: key, value: node)
          buildFiles[key] = file
        case "PBXFileReference":
          let file = FileReference(key: key, value: node, title: title(key, titles: titles), projectPath: projectPath)
          fileReferences[key] = file
        case "PBXLegacyTarget":
          let target = LegacyTarget(key: key, value: node)
          legacyTargets.append(target)
        case "PBXNativeTarget":
          let target = NativeTarget(key: key, value: node)
          nativeTargets.append(target)
        case "PBXResourcesBuildPhase":
          let phase = ResourcesBuildPhase(key: key, value: node)
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
          let containerItemProxy = ContainerItemProxy(key: key, value: node)
          containerItemProxies.append(containerItemProxy)
        case "PBXProject":
          let project = ProjectNode(key: key, value: node)
          projectNodes.append(project)
        case "PBXFrameworksBuildPhase":
          let buildPhase = FrameworksBuildPhase(key: key, value: node)
          frameworksBuildPhases.append(buildPhase)
        case "PBXShellScriptBuildPhase":
          let buildPhase = ShellScriptBuildPhase(key: key, value: node)
          shellScriptBuildPhases.append(buildPhase)
        case "PBXSourcesBuildPhase":
          let buildPhase = SourcesBuildPhase(key: key, value: node)
          sourcesBuildPhases.append(buildPhase)
        case "PBXTargetDependency":
          let targetDependency = TargetDependency(key: key, value: node)
          targetDependencies.append(targetDependency)
        case "PBXVariantGroup":
          let variantGroup = VariantGroup(key: key, value: node)
          variantGroups.append(variantGroup)
        case "PBXCopyFilesBuildPhase":
          let buildPhase = CopyFilesBuildPhase(key: key, value: node)
          copyFilesPhases.append(buildPhase)
        case "PBXAggregateTarget":
          break
        case "PBXHeadersBuildPhase":
          break
        case "XCSwiftPackageProductDependency":
          break
        case "XCRemoteSwiftPackageReference":
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
