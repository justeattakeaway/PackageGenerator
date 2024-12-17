//  DependencyHasher.swift

import Foundation

final class DependencyHasher {

    enum DependencyHasherError: Error, LocalizedError {
        case hashingFailed(name: String)
        case nonExistingHashingPath(path: String)

        var errorDescription: String? {
            switch self {
            case .hashingFailed(let name):
                return "Hashing failed for dependency \(name)"
            case .nonExistingHashingPath(let path):
                return "Hashing path does not exist at \(path)"
            }
        }
    }

    private let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func hashForPackage(at url: URL, requiredSubpaths: [String], optionalSubpaths: [String] = []) throws -> String {
        let name = url.lastPathComponent

        let relativePaths = try collectRelativePaths(at: url, requiredSubpaths: requiredSubpaths, optionalSubpaths: optionalSubpaths)
        let tarProcess = createTarProcess(at: url, paths: relativePaths)
        let shasumProcess = createShasumProcess()
        let awkProcess = createAwkProcess()

        connectProcesses(tar: tarProcess, shasum: shasumProcess, awk: awkProcess)

        try runProcesses([tarProcess, shasumProcess, awkProcess])

        return try collectHashOutput(from: awkProcess, moduleName: name)
    }

    // MARK: - Helper Methods

    private func collectRelativePaths(at url: URL, requiredSubpaths: [String], optionalSubpaths: [String] = []) throws -> [String] {
        let fileManager = FileManager.default

        var relativePaths: [String] = []

        for subpath in requiredSubpaths {
            let path = url.appendingPathComponent(subpath)
            guard fileManager.fileExists(atPath: path.path) else {
                throw DependencyHasherError.nonExistingHashingPath(path: path.path)
            }
            relativePaths.append(subpath)
        }

        for subpath in optionalSubpaths {
            let path = url.appendingPathComponent(subpath)
            if fileManager.fileExists(atPath: path.path) {
                relativePaths.append(subpath)
            }
        }
        
        return relativePaths
    }

    private func createTarProcess(at url: URL, paths: [String]) -> Process {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/tar")
        process.arguments = ["-cf", "-"] + paths
        process.currentDirectoryURL = url
        process.standardOutput = Pipe()
        process.standardError = Pipe()
        return process
    }

    private func createShasumProcess() -> Process {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/shasum")
        process.arguments = ["-a", "256"]
        process.standardOutput = Pipe()
        process.standardError = Pipe()
        return process
    }

    private func createAwkProcess() -> Process {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/awk")
        process.arguments = ["{ print $1 }"]
        process.standardOutput = Pipe()
        process.standardError = Pipe()
        return process
    }

    private func connectProcesses(tar: Process, shasum: Process, awk: Process) {
        guard let tarOutput = tar.standardOutput as? Pipe,
              let shasumOutput = shasum.standardOutput as? Pipe else {
            fatalError("Failed to connect process pipes.")
        }

        shasum.standardInput = tarOutput
        awk.standardInput = shasumOutput
    }

    private func runProcesses(_ processes: [Process]) throws {
        for process in processes {
            try process.run()
        }
        for process in processes {
            process.waitUntilExit()
        }
    }

    private func collectHashOutput(from awkProcess: Process, moduleName: String) throws -> String {
        guard let pipe = awkProcess.standardOutput as? Pipe else {
            throw DependencyHasherError.hashingFailed(name: moduleName)
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let hash = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            throw DependencyHasherError.hashingFailed(name: moduleName)
        }

        return hash
    }
}
