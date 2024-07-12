import Foundation

let fileManager = FileManager()

@main
private struct CreateProject {
    private enum Error: Swift.Error, LocalizedError {
        case invalidProjectPath(_ projectPath: String)

        var localizedDescription: String {
            switch self {
                case .invalidProjectPath(let path): "Invalid project path: \(path)"
            }
        }
    }

    static func main() throws {
        let projectPath = try UserChoice.get(message: "Where would you like this project to be created?: ")
        let projectName = try UserChoice.get(message: "Please enter your project name: ")
        
        let godotPath: String = switch ProcessInfo.processInfo.environment["GODOT"] {
            case .some(let value): value
            case .none: try UserChoice.get(message: "Please enter the full path to the Godot 4.2 executable: ")
        }

        try FileFactory.createProjectDirectory(atPath: projectPath)

        guard fileManager.changeCurrentDirectoryPath(projectPath) else {
            throw Error.invalidProjectPath(projectPath)
        }
        
        try FileFactory.createProjectDirectory(atPath: projectPath)
        try FileFactory.createEnvFile(projectName: projectName, godotPath: godotPath)
        try FileFactory.createSourcesDirectory()
        try FileFactory.createLibraryTarget(projectName: projectName)

        let executableName = projectName + "Game"
        try FileFactory.createExecutableTarget(projectName: projectName, executableName: executableName)
        try FileFactory.createPackageFile(projectName: projectName)

        try FileFactory.copyMakefile()
        try FileFactory.copyGDDFile()
        try FileFactory.copyGitIgnoreFile()
        try FileFactory.copyGodotDirectory()
        try FileFactory.createGodotProjectFile(projectName: projectName)
        try FileFactory.createGDExtensionFile(projectName: projectName)
        try FileFactory.copyReadmeFile()
        try FileFactory.createExportPresetsFile(projectName: projectName)
    }
}
