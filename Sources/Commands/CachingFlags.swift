//  CachingFlags.swift

import ArgumentParser

struct CachingFlags: ParsableArguments {

    @Flag(name: .long, help: "Whether to use binary targets for dependencies.")
    var dependenciesAsBinaryTargets: Bool = false

    @Option(name: .long, help: "Path to a folder containing dependencies. Required if --dependencies-as-binary-targets is set.")
    var relativeDependenciesPath: String?

    @Option(name: .long, help: "Path to a file containing the the version references for the dependencies (either hashes or SemVer versions). Required if --dependencies-as-binary-targets is set.")
    var versionRefsPath: String?

    @Option(name: .long, help: "List of dependencies to exclude from the list of binary targets. Effective only if --dependencies-as-binary-targets is set.")
    var exclusions: [String] = []
}
