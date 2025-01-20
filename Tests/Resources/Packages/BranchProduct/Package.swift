// swift-tools-version: 5.7

// This file was automatically generated by PackageGenerator and untracked
// PLEASE DO NOT EDIT MANUALLY

import PackageDescription

let package = Package(
    name: "BranchProduct",
    defaultLocalization: "en",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "BranchProduct",
            targets: ["TargetA"]
        ),
    ],
    dependencies: [
        .package(
            path: "../LocalDependencies"
        ),
        .package(
            url: "https://github.com/RemoteDependencyA",
            exact: "1.0.0"
        ),
        .package(
            url: "https://github.com/RemoteDependencyB",
            exact: "2.0.0"
        ),
        .package(
            url: "https://github.com/RemoteDependencyD",
            branch: "master"
        ),
    ],
    targets: [
        .target(
            name: "TargetA",
            dependencies: [
                .product(name: "LocalDependencyA", package: "LocalDependencyA"),
                .product(name: "RemoteDependencyA", package: "RemoteDependencyA"),
                .product(name: "RemoteDependencyB", package: "RemoteDependencyB"),
                .product(name: "RemoteDependencyD", package: "RemoteDependencyD"),
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
                .product(name: "RemoteDependencyB", package: "RemoteDependencyB"),
            ],
            path: "Tests/Sources",
            resources: [
                .process("Resources")
            ],
            plugins: [
            ]
        ),
    ]
)