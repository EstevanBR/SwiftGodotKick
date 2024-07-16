import Foundation

enum UserChoice {
    enum Error: Swift.Error, LocalizedError {
        case missingUserChoice

        var errorDescription: String? {
            "Recieved no input from user"
        }
    }
    
    static func get(message: String) throws -> String {
        print(message, terminator: "")
        guard let choice = readLine(strippingNewline: true), choice.isEmpty == false else {
            throw Error.missingUserChoice
        }
        return choice
    }
}