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

public enum Report: Equatable {
  case invalidInput
  case failed(errors: [String])
  case passed

  public var errors: [String] {
    guard case let .failed(errors) = self else {
      return []
    }
    return errors
  }
}

public enum ReportKind: StringEnumArgument {
  case warning
  case error

  public init?(rawValue: String) {
    switch rawValue {
    case "error":
      self = .error
    case "warning":
      self = .warning
    default:
      return nil
    }
  }

  public static var completion = ShellCompletion.values([("error", ""), ("warning", "")])
  public static var usage = "Either 'error' or 'warning'"
}

extension ReportKind {
  public var logEntry: String {
    switch self {
    case .error:
      return "error:"
    case .warning:
      return "warning:"
    }
  }

  public var returnType: Int32 {
    switch self {
    case .error:
      return EX_SOFTWARE
    case .warning:
      return EX_OK
    }
  }
}
