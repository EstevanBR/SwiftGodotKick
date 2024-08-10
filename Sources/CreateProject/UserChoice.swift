import Foundation

enum UserChoice {
    enum Error: Swift.Error, LocalizedError {
        case missingUserChoice
        case invalidInputForBoolean

        var errorDescription: String? {
            switch self {
                case .missingUserChoice: "Recieved no input from user"
                case .invalidInputForBoolean: "Invalid input expect \"y\" or \"n\""
            }
        }
    }

    static var shouldColorizeOutput: Bool = {
        !ProcessInfo.processInfo.arguments.contains(Argument.noColor.rawValue)
    }()

    static var shouldHelp: Bool = {
        ProcessInfo.processInfo.arguments.contains(Argument.help.rawValue)
    }()

    static var shouldShowVersion: Bool = {
        ProcessInfo.processInfo.arguments.contains(Argument.version.rawValue)
    }()
    
    static func get(message: String) throws -> String {
        print(message, terminator: "")
        guard let choice = readLine(strippingNewline: true), choice.isEmpty == false else {
            throw Error.missingUserChoice
        }
        return choice
    }

    static func getBool(message: String) throws -> Bool {
        print(message, terminator: " (y/n): ")
        guard let choice = readLine(strippingNewline: true), choice.isEmpty == false else {
            throw Error.missingUserChoice
        }
        if choice.lowercased().first == "y" {
            return true
        } else if choice.lowercased().first == "n" {
            return false
        } else {
            throw Error.invalidInputForBoolean
        }
    }
}
