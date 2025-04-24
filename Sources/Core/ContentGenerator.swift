//  ContentGenerator.swift

import Foundation

struct ContentGenerator {

    func content(for spec: Spec, templateUrl: URL) throws -> Content {
        let templater = Templater(templateUrl: templateUrl)
        return try templater.renderTemplate(context: spec.makeContext())
    }

    func content(for dependencies: Dependencies, localModules: [LocalModule], templateUrl: URL) throws -> Content {
        let templater = Templater(templateUrl: templateUrl)
        let localModulesDicts: [[String: String]] = localModules.map { module in
            var localModule: [String: String] = [
                "name": module.name,
                "path": module.relativePath
            ]
            if let productType = module.productType {
                localModule["product_type"] = productType
            }
            return localModule
        }

        var final = dependencies.makeContext()
        final["local_modules"] = localModulesDicts

        return try templater.renderTemplate(context: final)
    }
}
