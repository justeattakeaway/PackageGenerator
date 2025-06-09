//  ContentGenerator.swift

import Foundation

struct ContentGenerator {

    func content(for spec: Spec, templateUrl: URL) throws -> Content {
        let templater = Templater(templateUrl: templateUrl)
        return try templater.renderTemplate(context: spec.makeContext())
    }

    func content(packageDependencies: Dependencies, targetDependencies: TargetDependencies, templateUrl: URL, modulesRelativePath: String) throws -> Content {
        let localTargetDependencies = targetDependencies.dependencies
            .filter { $0.type == .local }
            .reduce(into: [TargetDependency]()) { result, element in
                if !result.contains(element) {
                    result.append(element)
                }
            }
        let remoteTargetDependencies = targetDependencies.dependencies
            .filter { $0.type == .remote || $0.type == .registry }
            .reduce(into: [TargetDependency]()) { result, element in
                if !result.contains(element) {
                    result.append(element)
                }
            }

        let localModulesDicts: [[String: String]] = localTargetDependencies
            .map { localTargetDependency in
                let localModule: [String: String] = [
                    "name": localTargetDependency.name,
                    // the ../ is needed as Package.swift is meant ot be in the Tuist folder
                    "path": "../\(modulesRelativePath)/\(localTargetDependency.name)"
                ]
                return localModule
            }
            .reduce(into: [[String: String]]()) { result, element in
                if !result.contains(element) {
                    result.append(element)
                }
            }

        // Starting from all the package dependencies, only keep those that appear
        // in the list of target dependencies (i.e. are actually used by the targeting app)
        let filteredDependencies = packageDependencies.dependencies
            .filter( { packageDependency in
                !remoteTargetDependencies
                    .filter( { remoteTargetDependency in
                        remoteTargetDependency.name == packageDependency.name
                    })
                    .isEmpty
            })

        var final = Dependencies(dependencies: filteredDependencies).makeContext()
        final["local_modules"] = localModulesDicts

        let templater = Templater(templateUrl: templateUrl)
        return try templater.renderTemplate(context: final)
    }
}
