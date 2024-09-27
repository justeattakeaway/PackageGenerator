// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PackageGenerator",
    platforms: [.macOS(.v12)],
    products: [
        .executable(name: "PackageGenerator", targets: ["PackageGenerator"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.1.2"),
        .package(url: "https://github.com/SwiftGen/StencilSwiftKit", from: "2.8.0"),
        .package(url: "https://github.com/JohnSundell/ShellOut", from: "2.3.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.6"),
        .package(url: "https://github.com/glwithu06/Semver.swift.git", from: "1.2.0")
    ],
    targets: [
        .executableTarget(
            name: "PackageGenerator",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "ShellOut", package: "ShellOut"),
                .product(name: "StencilSwiftKit", package: "StencilSwiftKit"),
                .product(name: "Yams", package: "Yams"),
                .product(name: "Semver", package: "Semver.swift")
            ],
            path: "Sources"),
        .testTarget(
            name: "PackageGeneratorTests",
            dependencies: ["PackageGenerator"],
            path: "Tests",
            resources: [
                .copy("Resources")
            ]
        )
    ]
)
