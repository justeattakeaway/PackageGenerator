//  ContentGenerator.swift

import Foundation

struct ContentGenerator {

    func content(for spec: Spec, templateUrl: URL) throws -> Content {
        let templater = Templater(templateUrl: templateUrl)
        return try templater.renderTemplate(context: spec.makeContext())
    }
}
