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
import TSCUtility
import xcprojectlint_package

func noteSuccess() {
  let processInfo = ProcessInfo.processInfo
  let env = processInfo.environment

  if let output = env["SCRIPT_OUTPUT_FILE_0"] {
    print("Touching \(output)")
    try? "OK".write(toFile: output, atomically: false, encoding: .utf8)
  }
}

func main() -> Int32 {
  do {
    let parser = ArgumentParser(usage: "<options>", overview: "Xcode project linter")
    let versionArg: OptionArgument<Bool> = parser.add(option: "--version", kind: Bool.self, usage: Usage.version)
    let reportArg: OptionArgument<ReportKind> = parser.add(option: "--report", kind: ReportKind.self, usage: ReportKind.usage)
    let validationsArg: OptionArgument<[Validation]> = parser.add(option: "--validations", kind: [Validation].self, usage: Validation.usage)
    let projectArg: OptionArgument<PathArgument> = parser.add(option: "--project", kind: PathArgument.self, usage: Usage.project)
    let skipFoldersArg: OptionArgument<[String]> = parser.add(option: "--skip-folders", kind: [String].self, usage: Usage.skipFolders)
    let sortByNameArg: OptionArgument<Bool> = parser.add(option: "--sort-by-name", kind: Bool.self, usage: Usage.sortByName)

    // The first argument is always the executable, so drop it
    var processArgs = ProcessInfo.processInfo.arguments.dropFirst()
    // Special case for "no arguments"
    if processArgs.isEmpty {
      processArgs = ["--help"]
    }
    let arguments = Array(ProcessInfo.processInfo.arguments.dropFirst())
    let args = try parser.parse(arguments)

    // fast path out if the version was requested
    if args.get(versionArg) != nil {
      print("xcprojectlint version \(currentVersion)")
      return EX_OK
    }

    // otherwise, check for the required arguments
    var missingArgs = [String]()
    if args.get(reportArg) == nil {
      missingArgs.append("--report")
    }
    if args.get(validationsArg) == nil {
      missingArgs.append("--validations")
    }
    if args.get(projectArg) == nil {
      missingArgs.append("--project")
    }
    if !missingArgs.isEmpty {
      throw ArgumentParserError.expectedArguments(parser, missingArgs)
    }

    // We're all set. Instead of force unwrapping these things, let
    // the `guard` do it for us. Something has gone horribly wrong if
    // do don’t get the values we just checked for.
    guard let reportKind = args.get(reportArg),
      var validations = args.get(validationsArg),
      let proj = args.get(projectArg) else { return EX_SOFTWARE }

    let skipFolders = args.get(skipFoldersArg)
    let sortByName = args.get(sortByNameArg)
    if validations.last == .all {
      validations = Validation.allValidations()
    }

    let errorReporter = ErrorReporter(pbxprojPath: proj.path.description, reportKind: reportKind)
    let project = try Project(proj.path.description, errorReporter: errorReporter)
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
        return ensureAlphaOrder(project, logEntry: logEntry, sortByName: sortByName ?? false, skipFolders: skipFolders)
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
      noteSuccess()
    }
    return scriptResult
  } catch let error as ArgumentParserError {
    print(error.description)
  } catch {
    print(error.localizedDescription)
  }
  return EX_DATAERR
}

exit(main())
