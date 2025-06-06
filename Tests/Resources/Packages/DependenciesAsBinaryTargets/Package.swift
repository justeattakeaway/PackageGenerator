// swift-tools-version: 6.0

// This file was automatically generated by PackageGenerator and is untracked
// PLEASE DO NOT EDIT MANUALLY

import PackageDescription

let package = Package(
    name: "DependenciesAsBinaryTargets",
    defaultLocalization: "en",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "DependenciesAsBinaryTargets",
            targets: ["TargetA"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "TargetA",
            dependencies: [
                .target(name: "LocalDependencyA"),
                .target(name: "RemoteDependencyA"),
                .target(name: "RemoteDependencyB"),
            ],
            path: "Framework/Sources",
            resources: [
                .process("Resources")
            ],
            plugins: [
            ]
        ),
        .testTarget(
            name: "TargetATests",
            dependencies: [
                .byName(name: "TargetA"),
                .target(name: "LocalDependencyA"),
                .target(name: "RemoteDependencyA"),
                .target(name: "RemoteDependencyB"),
            ],
            path: "Tests/Sources",
            resources: [
                .process("Resources")
            ],
            plugins: [
            ]
        ),
        .binaryTarget(
            name: "LocalDependencyA",
            path: "../.xcframeworks/LocalDependencyA/someVersionRefForLocalDependencyA/LocalDependencyA.xcframework"
        ),
        .binaryTarget(
            name: "RemoteDependencyA",
            path: "../.xcframeworks/RemoteDependencyA/someVersionRefForRemoteDependencyA/RemoteDependencyA.xcframework"
        ),
        .binaryTarget(
            name: "RemoteDependencyB",
            path: "../.xcframeworks/RemoteDependencyB/someVersionRefForRemoteDependencyB/RemoteDependencyB.xcframework"
        ),
    ]
)