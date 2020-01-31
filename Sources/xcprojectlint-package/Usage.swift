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

public struct Usage {
  public static let version = "The version of the tool"
  public static let project = "Path to the project.xcproject file"

  public static let skipFolders =
    """
    List of folders to ignore during `disk-layout-matches-project`.
                         Useful for Frameworks, Products, and/or source trees
                         that aren’t chidren to the project file
    """

  public static let sortByName =
    """
    Sort order for `items-in-alpha-order` is the same as Xcode's
                         `Sort by Name` Project Navigator command
    """
}
