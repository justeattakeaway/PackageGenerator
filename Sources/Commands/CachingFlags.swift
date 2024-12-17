//  CachingFlags.swift

import ArgumentParser

struct CachingFlags: ParsableArguments {

    @Flag(name: .long, help: "Whether to use binary targets for dependencies.")
    var dependenciesAsBinaryTargets: Bool = false

    @Option(name: .long, help: "Path to a folder containing dependencies. Required if --dependencies-as-binary-targets is set.")
    var relativeDependenciesPath: String?

    @Option(name: .long, help: "List of required relative paths to use when generating the hash for local dependencies. Required if --dependencies-as-binary-targets is set.")
    var requiredHashingPaths: [String] = []

    @Option(name: .long, help: "List of optional relative paths to use when generating the hash for local dependencies.")
    var optionalHashingPaths: [String] = []

    @Option(name: .long, help: "List of dependencies to exclude from the list of binary targets.")
    var exclusions: [String] = []
}
