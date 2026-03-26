//  Printer.swift

struct Printer {
    let quiet: Bool

    func print(_ message: String) {
        if !quiet {
            Swift.print(message)
        }
    }
}
