// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

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

import PackageDescription

let package = Package(
  name: "xcprojectlint",
  products: [
    .library(
      name: "xcprojectlint-package",
      targets: ["xcprojectlint-package"]
    ),
    .executable(
      name: "xcprojectlint",
      targets: ["xcprojectlint"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-tools-support-core.git", from: "0.4.0"),
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
  ],
  targets: [
    .executableTarget(
      name: "xcprojectlint",
      dependencies: [
        .byName(name: "xcprojectlint-package"),
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "SwiftToolsSupport", package: "swift-tools-support-core"),
      ]
    ),
    .target(
      name: "xcprojectlint-package",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "SwiftToolsSupport", package: "swift-tools-support-core"),
      ]
    ),
    .testTarget(
      name: "xcprojectlint-packageTests",
      dependencies: [
        .byName(name: "xcprojectlint-package"),
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "SwiftToolsSupport", package: "swift-tools-support-core"),
      ],
      resources: [
        .copy("TestData")
      ]
    ),
  ]
)
