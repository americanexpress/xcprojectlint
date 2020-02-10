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

public func checkForInternalProjectSettings(_ project: Project, pbxprojPath: String, logEntry: String) -> Report {
  let errors = project.buildConfigurations
    .filter { !$0.buildSettings.isEmpty }
    .map { buildConfiguration -> String in
      guard let title = project.titles[buildConfiguration.id] else {
        let error = ProjectSettingsError.problemLocatingMatchingConfiguration
        return "\(pbxprojPath):0: \(logEntry) \(error.localizedDescription)\n"
      }

      var matchingTarget: String?
      if let base = buildConfiguration.baseConfigurationReference {
        matchingTarget = project.titles[base]
      } else {
        let target = project.legacyTargets.filter { $0.buildConfigurationList == buildConfiguration.id }
        matchingTarget = target.last?.name
      }

      // see if we can find the buildSettings node closest to this build configuration
      var currentLine = 0
      var foundKey = false
      for line in project.projectText.components(separatedBy: CharacterSet.newlines) {
        currentLine += 1
        if !foundKey {
          if line.contains(buildConfiguration.id) {
            foundKey = true
          }
        } else {
          if line.contains("buildSettings") {
            break
          }
        }
      }

      // NOTE: The spaces around the error: portion of the string are required with Xcode 8.3. Without them, no output gets reported in the Issue Navigator.
      if let matchingTarget = matchingTarget {
        return "\(project.url.path):\(currentLine): \(logEntry) \(matchingTarget) (\(buildConfiguration.name)) has settings defined in the project file.\n"
      } else {
        return "\(project.url.path):\(currentLine): \(logEntry) \(title) has settings defined at the project level.\n"
      }
    }

  return errors.isEmpty ? .passed : .failed(errors: errors.sorted())
}

enum ProjectSettingsError: String, Error {
  // Some assumption we've made about the shape of a project file was wrong.
  case problemLocatingMatchingConfiguration = "We found buildSettings, but were not able to find the matching configuration."
}
