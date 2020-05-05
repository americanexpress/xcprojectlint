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

public enum Validation: String, StringEnumArgument {
  case buildSettingsExternalized = "build-settings-externalized"
  case diskLayoutMatchesProject = "disk-layout-matches-project"
  case filesExistOnDisk = "files-exist-on-disk"
  case itemsInAlphaOrder = "items-in-alpha-order"
  case noDanglingSourceFiles = "dangling-source-files"
  case noEmptyGroups = "empty-groups"
  case noWhiteSpaceSpecifications = "no-white-space-specifications"

  case all

  public init(_ argument: String) throws {
    guard let validation = Validation(rawValue: argument) else {
      throw ArgumentConversionError.typeMismatch(value: argument, expectedType: Validation.self)
    }

    self = validation
  }

  public static let completion: ShellCompletion = .values([(value: "Test", description: "Test2")])

  public static let usage =
    """
    List of validations to perform:
                         build-settings-externalized:
                           Looks for project settings defined in the project file

                         dangling-source-files:
                           Ensures each source code files is member of a target

                         disk-layout-matches-project:
                           Validates files on disk are arranged like the project
                           file

                         empty-groups:
                           Reports groups that have no children

                         files-exist-on-disk:
                           Look for files referenced by the project that are not
                           found on disk

                         items-in-alpha-order:
                           Ensure groups and files are sorted alphabetically

                         no-white-space-specifications:
                           Ensure user specifications of tabs, tabWidth, and identWidth
                           are not carried through project file.

                         all:
                           Runs all known validations
    """

  public static func allValidations() -> [Validation] {
    return [
      Validation.buildSettingsExternalized,
      Validation.diskLayoutMatchesProject,
      Validation.filesExistOnDisk,
      Validation.itemsInAlphaOrder,
      Validation.noDanglingSourceFiles,
      Validation.noEmptyGroups,
      Validation.noWhiteSpaceSpecifications,
    ]
  }
}
