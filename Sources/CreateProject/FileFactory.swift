import Foundation

enum FileFactory {
    private enum Error: Swift.Error, LocalizedError {
        case couldNotCreateFile(path: String)
        case noURLForResource(resource: String, extension: String?)

        var errorDescription: String? {
            switch self {
                case .couldNotCreateFile(let path): "Could not create file: \(path)"
                case let .noURLForResource(resource, .none): "Could not create URL for resource: \(resource)"
                case let .noURLForResource(resource, .some(ext)): "Could not create URL for resource: \(resource).\(ext)"
            }
        }
    }

    private static let fileManager = FileManager()

    static func createProjectDirectory(atPath path: String, projectName: String) throws -> String {
        let projectDirectoryPath = path + (path.last == "/" ? "" : "/") + projectName
        try fileManager.createDirectory(atPath: projectDirectoryPath, withIntermediateDirectories: true)
        return projectDirectoryPath

    }

    static func createEnvFile(projectName: String, godotPath: String) throws -> String {
        let directory = fileManager.currentDirectoryPath
        let data = try DataFactory.makeEnvFileData(projectName: projectName, godotPath: godotPath)
        let path = directory + "/.env"
        fileManager.createFile(atPath: path, contents: data)
        return path
    }

    static func createSourcesDirectory() throws -> String {
        let directory = fileManager.currentDirectoryPath
        let path = directory + "/Sources"
        try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true)
        return path
    }

    static func createLibraryTarget(projectName: String) throws -> String {
        let directory = fileManager.currentDirectoryPath
        let libraryTargetDirectory = directory + "/Sources/\(projectName)"
        let librarySourceFile = libraryTargetDirectory + "/" + projectName + ".swift"
        try fileManager.createDirectory(atPath: libraryTargetDirectory, withIntermediateDirectories: true)
        let libraryFileData = try DataFactory.makeLibraryFileData()
        try fileManager.createFile(atPath: librarySourceFile, contents: libraryFileData, replace: false)
        return librarySourceFile
    }

    static func createExecutableTarget(projectName: String) throws -> String {
        let executableName = projectName + "Game"
        let directory = fileManager.currentDirectoryPath
        let executableTargetDirectory = directory + "/Sources/\(executableName)"

        try fileManager.createDirectory(atPath: executableTargetDirectory, withIntermediateDirectories: true)
        let mainFileData = try DataFactory.makeMainFileData(projectName: projectName)
        let mainPath = executableTargetDirectory + "/main.swift"
        fileManager.createFile(atPath: mainPath, contents: mainFileData)

        let resourcesDirectory = executableTargetDirectory + "/Resources"
        try fileManager.createDirectory(atPath: resourcesDirectory, withIntermediateDirectories: true)

        return mainPath
    }

    static func createPackageFile(projectName: String) throws -> String {
        let directory = fileManager.currentDirectoryPath
        let path = directory + "/Package.swift"
        let data = try DataFactory.makePackageFileData(projectName: projectName)
        guard fileManager.createFile(atPath: path, contents: data) else {
            throw Error.couldNotCreateFile(path: path)
        }
        return path
    }

    static func createGodotProjectFile(projectName: String) throws -> String {
        let directory = fileManager.currentDirectoryPath
        let path = directory + "/godot/project.godot"
        let data = try DataFactory.makeGodotProjectFileData(projectName: projectName)
        guard fileManager.createFile(atPath: path, contents: data) else {
            throw Error.couldNotCreateFile(path: path)
        }
        return path
    }

    static func createGDExtensionFile(projectName: String) throws -> String {
        let directory = fileManager.currentDirectoryPath
        let path = directory + "/godot/\(projectName).gdextension"
        let data = try DataFactory.makeGDExtensionFileData(projectName: projectName)
        guard fileManager.createFile(atPath: path, contents: data) else {
            throw Error.couldNotCreateFile(path: path)
        }
        return path
    }

    static func createExportPresetsFile(projectName: String) throws -> String {
        let directory = fileManager.currentDirectoryPath
        let data = try DataFactory.makeExportPresetsFileData(projectName: projectName)
        let path = directory + "/godot/export_presets.cfg"
        guard fileManager.createFile(atPath: path, contents: data) else {
            throw Error.couldNotCreateFile(path: path)
        }
        return path
    }

    static func copyMakefile() throws -> String {
        guard let url = Bundle.module.url(forResource: "Makefile", withExtension: nil) else {
            throw Error.noURLForResource(resource: "Makefile", extension: nil)
        }
        let directory = fileManager.currentDirectoryPath
        let destinationPath = directory + "/Makefile"
        try fileManager.copyItem(atPath: url.path, toPath: destinationPath)
        return destinationPath
    }

    static func copyGDDFile() throws -> String {
        guard let url = Bundle.module.url(forResource: "GDD", withExtension: "md") else {
            throw Error.noURLForResource(resource: "Makefile", extension: "md")
        }
        let directory = fileManager.currentDirectoryPath
        let destinationPath = directory + "/GDD.md"
        try fileManager.copyItem(atPath: url.path, toPath: destinationPath)
        return destinationPath
    }

    static func copyGitIgnoreFile() throws -> String {
        guard let url = Bundle.module.url(forResource: ".gitignore", withExtension: nil) else {
            throw Error.noURLForResource(resource: ".gitignore", extension: nil)
        }
        let directory = fileManager.currentDirectoryPath
        let destinationPath = directory + "/.gitignore"
        try fileManager.copyItem(atPath: url.path, toPath: destinationPath)
        return destinationPath
    }

    static func copyGodotDirectory() throws -> String {
        guard let url = Bundle.module.url(forResource: "godot", withExtension: nil) else {
            throw Error.noURLForResource(resource: "godot", extension: nil)
        }
        let directory = fileManager.currentDirectoryPath
        
        let destinationPath = directory + "/godot"
        try fileManager.copyItem(atPath: url.path, toPath: destinationPath)
        return destinationPath
    }

    static func copyReadmeFile() throws -> String {
        guard let url = Bundle.module.url(forResource: "README", withExtension: "md") else {
            throw Error.noURLForResource(resource: "README", extension: "md")
        }
        let directory = fileManager.currentDirectoryPath
        let destinationPath = directory + "/README.md"
        try fileManager.copyItem(atPath: url.path, toPath: destinationPath)
        return destinationPath
    }
}