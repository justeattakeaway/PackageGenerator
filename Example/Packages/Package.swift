// swift-tools-version: 6.0

// This file was automatically generated by PackageGenerator and untracked
// PLEASE DO NOT EDIT MANUALLY

import PackageDescription

let package = Package(
    name: "Example",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "Example",
            targets: ["Example"]
        ),
    ],
    dependencies: [
        .package(
            path: "../MyFrameworks"
        ),
        .package(
            url: "https://github.com/DependencyA",
            exact: "1.0.0"
        ),
        .package(
            url: "https://github.com/DependencyB",
            exact: "2.0.0"
        ),
        .package(
            url: "https://github.com/DependencyC",
            revision: "abcde1235kjh"
        ),
    ],
    targets: [
        .target(
            name: "Example",
            dependencies: [
                .product(name: "RemoteDependencyA", package: "RemoteDependencyA"),
                .target(name: "LocalXCFramework"),
            ],
            path: "Framework/Sources",
            resources: [
                .process("Resources")
            ],
            plugins: [
            ]
        ),
        .testTarget(
            name: "UnitTests",
            dependencies: [
                .byName(name: "Example"),
                .product(name: "RemoteDependencyB", package: "RemoteDependencyB"),
                .target(name: "LocalXCFramework"),
            ],
            path: "Tests/Sources",
            resources: [
                .process("Resources")
            ],
            plugins: [
            ]
        ),
        .binaryTarget(
            name: "LocalXCFramework",
            path: "../LocalXCFramework.xcframework"
        ),
    ],
    swiftLanguageModes: [
        .version("5.10"),
        .version("6.0"),
    ]
)
