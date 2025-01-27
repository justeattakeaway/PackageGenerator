//  DependencyFinding.swift

import Foundation

protocol DependencyFinding {
    func findPackageDependencies(at url: URL, versionRefsPath: String) async throws -> [PackageDependency]
}
