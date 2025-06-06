// swift-tools-version: 6.0

// This file was automatically generated by PackageGenerator and is untracked
// PLEASE DO NOT EDIT MANUALLY

import PackageDescription

#if TUIST
    import struct ProjectDescription.PackageSettings

    let packageSettings = PackageSettings(
        productTypes: [
            "LocalDependencyA": .staticFramework,
            "LocalDependencyB": .staticFramework,
            "LocalDependencyC": .staticFramework,
            "RemoteDependencyA": .staticFramework,
            "RemoteDependencyB": .staticFramework,
            "RemoteDependencyC": .staticFramework
        ]
    )
#endif

let package = Package(
    name: "JustEatTakeaway",
    dependencies: [
        .package(path: "../Modules/LocalDependencyA"),
        .package(path: "../Modules/LocalDependencyB"),
        .package(path: "../Modules/LocalDependencyC"),
        .package(url: "https://github.com/RemoteDependencyA", exact: "1.0.0"),
        .package(url: "https://github.com/RemoteDependencyB", exact: "2.0.0"),
        .package(url: "https://github.com/RemoteDependencyC", revision: "abcde1235kjh")
    ]
)
