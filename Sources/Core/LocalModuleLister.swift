//  LocalModuleLister.swift

import Foundation

struct LocalModuleLister: LocalModuleListing {

    private let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func listLocalModules(at relativePath: String) throws -> [LocalModule] {
        let currentDirectoryURL = URL(fileURLWithPath: fileManager.currentDirectoryPath, isDirectory: true)
        let targetDirectoryURL = currentDirectoryURL.appendingPathComponent(relativePath)

        let contents = try fileManager.contentsOfDirectory(
            at: targetDirectoryURL,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        )

        return try contents.compactMap { moduleUrl -> LocalModule? in
            let resourceValues = try moduleUrl.resourceValues(forKeys: [.isDirectoryKey])
            if resourceValues.isDirectory == true {
                let subfolderName = moduleUrl.lastPathComponent
                // the ../ is needed as the Package.swift is meant ot be in the Tuist folder
                let resultPath = "../" + (relativePath as NSString).appendingPathComponent(subfolderName)
                return LocalModule(name: subfolderName, relativePath: resultPath)
            } else {
                return nil
            }
        }
        .sorted { $0.name < $1.name }
    }
}
