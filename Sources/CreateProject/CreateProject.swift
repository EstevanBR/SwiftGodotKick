import Foundation

@main
private struct CreateProject {
    static let fileManager = FileManager()

    static func main() throws {
        do {
            let projectPath: String = try UserChoice.get(message: "Please enter where you would like the project directory to be created: ")

            let (projectPathExists, projectPathIsDirectory) = fileManager.directoryExists(atPath: projectPath)
            
            if !projectPathExists, !projectPathIsDirectory {
                if try UserChoice.getBool(message: Color.yellow + "There is no directory at path: \(projectPath), would you like to create it?") {
                    try fileManager.createDirectory(atPath: projectPath, withIntermediateDirectories: true)
                } else {
                    print("Goodbye")
                    exit(1)
                }
            }

            guard fileManager.changeCurrentDirectoryPath(projectPath) else {
                throw ChangeDirectoryError(path: projectPath)
            }

            let projectName: String = try UserChoice.get(message: "Please enter the name of the project: ")
            let contents = try fileManager.contentsOfDirectory(atPath: fileManager.currentDirectoryPath)
            guard contents.isEmpty else {
                print(color: .red, "Directory at \(projectPath) must be empty, but found: \(contents.joined(separator: ", "))")
                exit(1)
            }

            let executableName: String = try UserChoice.get(message: "Please enter the name of the executable: ")

            guard try UserChoice.getBool(message: "Project will be created at: \(fileManager.currentDirectoryPath + "/Package.swift, would you like to proceed?")") else {
                do {
                    print("Removing \(fileManager.currentDirectoryPath)")
                    try fileManager.removeItem(atPath: fileManager.currentDirectoryPath)
                } catch {
                    print(color: .red, "Could not remove \(fileManager.currentDirectoryPath)")
                }
                print("Goodbye")
                exit(0)
            }

            let godotPath: String = switch ProcessInfo.processInfo.environment["GODOT"] {
                case .some(let value) where value.isEmpty == false: value
                default: try UserChoice.get(message: Color.yellow + "GODOT not set\n" + "Please enter the full path to the Godot 4.2 executable: ")
            }

            print(color: .green, "Created \(try FileFactory.createPackageFile(projectName: projectName, executableName: executableName))")
            print(color: .green, "Created \(try FileFactory.copyReadmeFile())")
            print(color: .green, "Created \(try FileFactory.copyGitIgnoreFile())")
            print(color: .green, "Created \(try FileFactory.createEnvFile(projectName: projectName, executableName: executableName, godotPath: godotPath))")
            print(color: .green, "Created \(try FileFactory.createSourcesDirectory())")
            print(color: .green, "Created \(try FileFactory.createLibraryTarget(projectName: projectName))")
            print(color: .green, "Created \(try FileFactory.createExecutableTarget(projectName: projectName, executableName: executableName))")
            print(color: .green, "Created \(try FileFactory.copyGDDFile())")
            print(color: .green, "Created \(try FileFactory.copyGodotDirectory())")
            print(color: .green, "Created \(try FileFactory.createGodotProjectFile(projectName: projectName))")
            print(color: .green, "Created \(try FileFactory.createGDExtensionFile(projectName: projectName))")
            print(color: .green, "Created \(try FileFactory.createExportPresetsFile(projectName: projectName))")
            print(color: .green, "Created \(try FileFactory.createMakefile(projectName: projectName))")
        } catch let error as LocalizedError {
            print(color: .red, "Error: \(error.errorDescription ?? error.localizedDescription)")
            if let recoverySuggestion = error.recoverySuggestion {
                print(color: .yellow, "Recovery suggestion: \(recoverySuggestion)")
            }
            exit(1)
        } catch let error{
            print(color: .red, "Error: \(error.localizedDescription)")
            exit(1)
        }

        print("""
        run the following command:

        cd \(fileManager.currentDirectoryPath) && make all
        """)
    }
}

func print(color: Color, _ message: String) {
    print(color + message)
}
