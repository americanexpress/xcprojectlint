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
import XCProjectLintFramework

@main
struct xcprojectlint: ParsableCommand {
  static var configuration = CommandConfiguration(
    abstract: "A linter for Xcode project files.",
    version: "\(currentVersion)"
  )

  struct Options: ParsableArguments {
    @Option(
      name: .long,
      help: ArgumentHelp(stringLiteral: ReportKind.usage)
    )
    var report: ReportKind

    @Option(
      name: .long,
      help: ArgumentHelp(stringLiteral: Usage.project)
    )
    var project: String

    @Option(
      name: .long,
      parsing: .upToNextOption,
      help: ArgumentHelp(stringLiteral: Validation.usage)
    )
    var validations: [Validation] = []

    @Option(
      name: .long,
      parsing: .upToNextOption,
      help: ArgumentHelp(stringLiteral: Usage.skipFolders)
    )
    var skipFolders: [String] = []

    @Flag(
      name: .long,
      help: ArgumentHelp(stringLiteral: Usage.sortByName)
    )
    var sortByName = false
  }

  @OptionGroup var options: Options

  mutating func run() throws {
    do {
      if options.validations.isEmpty {
        options.validations = Validation.allValidations()
      }

      let errorReporter = ErrorReporter(pbxprojPath: options.project, reportKind: options.report)
      let project = try Project(options.project, errorReporter: errorReporter)
      let logEntry = errorReporter.reportKind.logEntry
      let reports: [Report] = options.validations.compactMap {
        switch $0 {
        case .buildSettingsExternalized:
          checkForInternalProjectSettings(project, pbxprojPath: errorReporter.pbxprojPath, logEntry: logEntry)
        case .diskLayoutMatchesProject:
          diskLayoutMatchesProject(project, logEntry: logEntry, skipFolders: options.skipFolders)
        case .filesExistOnDisk:
          filesExistOnDisk(project, logEntry: logEntry)
        case .itemsInAlphaOrder:
          ensureAlphaOrder(project, logEntry: logEntry, sortByName: options.sortByName, skipFolders: options.skipFolders)
        case .noDanglingSourceFiles:
          checkForDanglingSourceFiles(project, logEntry: logEntry)
        case .noEmptyGroups:
          noEmptyGroups(project, logEntry: logEntry)
        case .noWhiteSpaceSpecifications:
          checkForWhiteSpaceSpecifications(project, logEntry: logEntry)
        case .all:
          // we should never get here; the parser expanded `all` into the individual cases
          nil
        }
      }

      reports
        .flatMap(\.errors)
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
