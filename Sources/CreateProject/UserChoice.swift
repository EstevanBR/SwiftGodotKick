import Foundation

enum UserChoice {
    enum Error: Swift.Error {
        case missingUserChoice
    }
    
    static func get(message: String) throws -> String {
        print(message, terminator: "")
        guard let choice = readLine(strippingNewline: true) else {
            throw Error.missingUserChoice
        }
        return choice
    }
}