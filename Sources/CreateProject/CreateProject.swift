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
        let projectParentDirectoryPath = try UserChoice.get(message: "Please enter where you would like the project directory to be created: ")
        let projectName = try UserChoice.get(message: "Please enter the name of the project: ")
        
        let godotPath: String = switch ProcessInfo.processInfo.environment["GODOT"] {
            case .some(let value): value
            case .none: try UserChoice.get(message: "Please enter the full path to the Godot 4.2 executable: ")
        }

        let projectPath = try FileFactory.createProjectDirectory(atPath: projectParentDirectoryPath, projectName: projectName)

        guard fileManager.changeCurrentDirectoryPath(projectPath) else {
            throw Error.invalidProjectPath(projectPath)
        }

        print("Created \(try FileFactory.createPackageFile(projectName: projectName))")
        print("Created \(try FileFactory.copyReadmeFile())")
        print("Created \(try FileFactory.copyGitIgnoreFile())")
        print("Created \(try FileFactory.createEnvFile(projectName: projectName, godotPath: godotPath))")
        print("Created \(try FileFactory.createSourcesDirectory())")
        print("Created \(try FileFactory.createLibraryTarget(projectName: projectName))")
        print("Created \(try FileFactory.createExecutableTarget(projectName: projectName))")
        print("Created \(try FileFactory.copyGDDFile())")
        print("Created \(try FileFactory.copyGodotDirectory())")
        print("Created \(try FileFactory.createGodotProjectFile(projectName: projectName))")
        print("Created \(try FileFactory.createGDExtensionFile(projectName: projectName))")
        print("Created \(try FileFactory.createExportPresetsFile(projectName: projectName))")
        print("Created \(try FileFactory.copyMakefile())")

        print("\n run `$ cd \(fileManager.currentDirectoryPath) && make all`")
    }
}
