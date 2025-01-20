//  MockDependencyFinder.swift

import Foundation
@testable import PackageGenerator

struct MockDependencyFinder: DependencyFinding {

    func findPackageDependencies(at url: URL, versionRefsPath: String) async throws -> [PackageDependency] {
        let file = URL(filePath: versionRefsPath, directoryHint: .notDirectory)
        let data = try Data(contentsOf: file)
        let dependencyReferences = try JSONDecoder().decode(DependenciesFile.self, from: data).dependencies
        return dependencyReferences.map {
            PackageDependency(
                name: $0.name,
                type: $0.name.lowercased().contains("local") ? .local(hash: $0.versionRef) : .remote(tag: $0.versionRef)
            )
        }
    }
}
