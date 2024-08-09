import Foundation

extension ProcessInfo {
    func string(for argument: UserChoice.Argument) -> String? {
        let arguments = ProcessInfo.processInfo.arguments

        guard let firstIndex = arguments.firstIndex(of: argument.rawValue) else {
            return nil
        }

        guard arguments.indices.contains(firstIndex + 1) else {
            return nil
        }

        return arguments[firstIndex + 1]
    }

    func bool(for argument: UserChoice.Argument) -> Bool? {
        let arguments = ProcessInfo.processInfo.arguments

        guard let firstIndex = arguments.firstIndex(of: argument.rawValue) else {
            return nil
        }

        guard arguments.indices.contains(firstIndex + 1) else {
            return nil
        }

        return Bool(arguments[firstIndex + 1])
    }
}

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

    enum Argument: String, CaseIterable {
        case help = "--help"
        case noColor = "--noColor"
        case projectName = "--projectName"
        case executableName = "--executableName"
        case projectPath = "--projectPath"
        case godotPath = "--godot"
        case version = "--version"

        var description: String {
            switch self {
                case .help: "show help info"
                case .noColor: "disable colorized output"
                case .version: "show current version"
                case .projectName: "project name"
                case .executableName: "executable name"
                case .godotPath: "path to Godot binary"
                case .projectPath: "path where Package.swift and other files will be saved"
            }
        }

        var usage: String {
            switch self {
                case .help, .noColor, .version:
                    rawValue
                
                case .projectName, .executableName: rawValue + " <name>"
                case .projectPath, .godotPath: rawValue + " <path>"
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
