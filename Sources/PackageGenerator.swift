//  PackageGenerator.swift

import Foundation
import ArgumentParser

@main
struct PackageGenerator: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        subcommands: [
            GeneratePackage.self,
            GenerateTuistPackage.self
        ])
}
