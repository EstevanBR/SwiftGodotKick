import Foundation

let version = "2.2.2"

@main
private struct CreateProject {
    static func main() throws {
        let fileManager = FileManager()

        showHelpIfNeeded()
        showVersionIfNeeded()

        do {
            let godotPath = try getGodotPath()

            let projectPath = try getProjectPath()

            try createProjectPathDirectoryIfNeeded(at: projectPath)

            guard fileManager.changeCurrentDirectoryPath(projectPath) else {
                throw ChangeDirectoryError(path: projectPath)
            }

            let contents = try fileManager.contentsOfDirectory(atPath: fileManager.currentDirectoryPath)
            guard contents.isEmpty else {
                print(color: .red, "Directory at \(projectPath) must be empty, but found: \(contents.joined(separator: ", "))")
                exit(1)
            }

            let projectName = try getProjectName()
            
            let executableName = try getExecutableName()
            
            if projectName == executableName {
                print(color: .red, "Project name and Executable Name must be different")
                exit(0)
            }

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

private func showHelpIfNeeded() {
    guard !UserChoice.shouldHelp else {
        print(UserChoice.Argument.allCases.map { $0.usage + "\n\t" + $0.description }.joined(separator: "\n"))
        exit(0)
    }
}

private func showVersionIfNeeded() {
    guard !UserChoice.shouldShowVersion else {
        print(version)
        exit(0)
    }
}

private func getProjectPath() throws -> String {
    try checkFor(.projectPath, promptIfNeeded: "Please enter where you would like the project directory to be created: ")
}

private func getProjectName() throws -> String {
    format(targetName: try checkFor(.projectName, promptIfNeeded: "Please enter the name of the project: "))
}

private func getExecutableName() throws -> String {
    try checkFor(.executableName, promptIfNeeded: "Please enter the name of the executable: ")
}

private func getGodotPath() throws -> String {
    let godotPath: String

    godotPath = if let godotPathFromEnv = ProcessInfo.processInfo.environment["GODOT"] {
        godotPathFromEnv
    } else {
        try UserChoice.get(message: Color.yellow + "Missing GODOT environment variable\n" + "Please enter the full path to the Godot 4.2 executable: ")
    }

    #if os(macOS)
    guard !godotPath.hasSuffix(".app") else {
        throw GodotPathError(path: godotPath)
    }
    #endif

    return godotPath
}

private func checkFor(_ argument: UserChoice.Argument, promptIfNeeded prompt: String) throws -> String {
    switch ProcessInfo.processInfo.string(for: argument) {
        case .some(let argument): argument
        case .none: try UserChoice.get(message: prompt)
    }
}

private func print(color: Color, _ message: String) {
    print(color + message)
}

private func createProjectPathDirectoryIfNeeded(at projectPath: String) throws {
    let fileManager = FileManager()
    let (projectPathExists, projectPathIsDirectory) = fileManager.directoryExists(atPath: projectPath)
    if !projectPathExists, !projectPathIsDirectory {
        if try UserChoice.getBool(message: Color.yellow + "There is no directory at path: \(projectPath), would you like to create it?") {
            try fileManager.createDirectory(atPath: projectPath, withIntermediateDirectories: true)
        } else {
            print("Goodbye")
            exit(1)
        }
    }
}

func format(targetName: String) -> String {
    var newName = ""
    let badCharacter: Set<Character> = [" ", "-"]
    // Upper case first one
    var uppercaseNext = true
    
    for character in targetName {
        if badCharacter.contains(character) {
            uppercaseNext = true
            continue
        }
        if uppercaseNext {
            newName.append(character.uppercased())
            uppercaseNext = false
            continue
        }
        newName.append(character)
    }
    return newName
}

#if os(macOS)
private struct GodotPathError: Swift.Error, LocalizedError {
    let path: String

    var errorDescription: String? {
        "\(path) ends in .app"
    }

    var recoverySuggestion: String? {
        "try \(path)/Contents/MacOS/Godot"
    }
}
#endif
