//  Dependencies+Context.swift

import Foundation

extension Dependencies {
    func makeContext() -> [String: Any] {
        let remoteDependencies = self.dependencies.map { dependency in
            var dict: [String: String] = [
                "name": dependency.name,
                "url": dependency.url
            ]

            switch dependency.ref {
            case .version(let value):
                dict["version"] = value
            case .revision(let value):
                dict["revision"] = value
            case .branch(let value):
                dict["branch"] = value
            }

            if let productType = dependency.productType {
                dict["product_type"] = productType
            }

            return dict
        }

        return [
            "remote_dependencies": remoteDependencies
        ]
    }
}
