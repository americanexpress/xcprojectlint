// swift-tools-version:5.9
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
    defaultLocalization: "en",

    // MARK: - Platforms

    platforms: [
        .macOS(.v10_15),
    ],

    // MARK: - Products

    products: [
        .library(name: "XCProjectLintFramework", targets: [ "XCProjectLintFramework" ]),
        .executable(name: "xcprojectlint", targets: [ "xcprojectlint" ]),
    ],

    // MARK: - Package Dependencies

    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", exact: "1.3.0"),
    ],

    // MARK: - Targets

    targets: [
        .executableTarget(
            name: "xcprojectlint",
            dependencies: [
                .byName(name: "XCProjectLintFramework"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),


        .target(
            name: "XCProjectLintFramework",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .testTarget(
            name: "XCProjectLintFrameworkTests",
            dependencies: [
                .byName(name: "XCProjectLintFramework"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            resources: [
                .copy("TestData")
            ]
        ),
    ]
)
