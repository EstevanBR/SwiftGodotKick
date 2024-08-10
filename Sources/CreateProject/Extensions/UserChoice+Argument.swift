extension UserChoice {
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
}
    