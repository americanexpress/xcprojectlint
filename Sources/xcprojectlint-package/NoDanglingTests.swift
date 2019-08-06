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

public func noDanglingTests(_ project: Project, errorReporter: ErrorReporter) -> Int32 {
    var result = EX_DATAERR

    let targetFiles = Set(project.buildFiles.map{$1.fileRef})
    let excludedExtensions = Set(["xctest", "h", "xcconfig", "xcfilelist"])
    let actualFilesInProjectNavigator = project.fileReferences
        .filter{ key, value in
            let fileComponents = value.title.components(separatedBy: ".")
            guard fileComponents.count > 1,
                let fileName = fileComponents.first?.hasSuffix("Tests"),
                fileName == true,
                !excludedExtensions.contains(fileComponents[1]),
                !targetFiles.contains(key) else {return false}
            return true
    }

    let results: [String] = actualFilesInProjectNavigator.map{
        "\(project.absolutePathToReference($1)):0: \(errorReporter.reportKind.logEntry) \($1.path) is not added to any test target.\n"
    }

    if results.count > 0 {

        result = errorReporter.reportKind.returnType
        for error in results {
            ErrorReporter.report(error)
        }
    } else {
        result = EX_OK
    }

    return result
}
