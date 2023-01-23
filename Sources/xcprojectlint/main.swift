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

import ArgumentParser
import Foundation
import xcprojectlint_package

var command = XCProjectLint()
try? command.run()

struct XCProjectLint: ParsableCommand {
  @Flag(help: ArgumentHelp(stringLiteral: Usage.version))
  var version = false

  @Option(name: .shortAndLong, help: ArgumentHelp(stringLiteral: ReportKind.usage))
  var report: ReportKind

  @Option(name: .shortAndLong, parsing: .upToNextOption, help: ArgumentHelp(stringLiteral: Validation.usage))
  var validations: [Validation] = []

  @Option(name: .shortAndLong, help: ArgumentHelp(stringLiteral: Usage.project))
  var project: String

  @Option(name: .shortAndLong, parsing: .upToNextOption, help: ArgumentHelp(stringLiteral: Usage.skipFolders))
  var skipFolders: [String] = []

  @Flag(help: ArgumentHelp(stringLiteral: Usage.sortByName))
  var sortByName = false

  mutating func run() throws {
    do {
      // If we’re run with no arguments, print out the usage banner
      if ProcessInfo.processInfo.arguments.dropFirst().isEmpty {
        throw (CleanExit.helpRequest())
      }

      // Fast path out if the version was requested
      if version {
        throw (CleanExit.message("xcprojectlint version \(currentVersion)"))
      }

      if validations.last == .all {
        validations = Validation.allValidations()
      }

      let errorReporter = ErrorReporter(pbxprojPath: project, reportKind: report)
      let project = try Project(project, errorReporter: errorReporter)
      let logEntry = errorReporter.reportKind.logEntry
      let reports: [Report] = validations.compactMap {
        switch $0 {
        case .buildSettingsExternalized:
          return checkForInternalProjectSettings(project, pbxprojPath: errorReporter.pbxprojPath, logEntry: logEntry)
        case .diskLayoutMatchesProject:
          return diskLayoutMatchesProject(project, logEntry: logEntry, skipFolders: skipFolders)
        case .filesExistOnDisk:
          return filesExistOnDisk(project, logEntry: logEntry)
        case .itemsInAlphaOrder:
          return ensureAlphaOrder(project, logEntry: logEntry, sortByName: sortByName, skipFolders: skipFolders)
        case .noDanglingSourceFiles:
          return checkForDanglingSourceFiles(project, logEntry: logEntry)
        case .noEmptyGroups:
          return noEmptyGroups(project, logEntry: logEntry)
        case .noWhiteSpaceSpecifications:
          return checkForWhiteSpaceSpecifications(project, logEntry: logEntry)
        case .all:
          // we should never get here; the parser expanded `all` into the individual cases
          return nil
        }
      }

      reports
        .flatMap { $0.errors }
        .forEach(ErrorReporter.report)

      let scriptResult = reports
        .map(errorReporter.toStatusCode)
        .reduce(EX_OK) { $0 | $1 }

      if scriptResult == EX_OK {
        let processInfo = ProcessInfo.processInfo
        let env = processInfo.environment

        if let output = env["SCRIPT_OUTPUT_FILE_0"] {
          print("Touching \(output)")
          try? "OK".write(toFile: output, atomically: false, encoding: .utf8)
        }
      }
      throw (ExitCode(scriptResult))
    } catch {
      print(error.localizedDescription)
    }
    throw (ExitCode(EX_DATAERR))
  }
}
