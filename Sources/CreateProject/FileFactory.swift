import Foundation

enum FileFactory {
    private enum Error: Swift.Error {
        case badURL
    }

    static func createProjectDirectory(atPath path: String) throws {
        try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true)
    }

    static func createEnvFile(projectName: String, godotPath: String) throws {
        let directory = fileManager.currentDirectoryPath
        let data = try DataFactory.makeEnvFileData(projectName: projectName, godotPath: godotPath)
        fileManager.createFile(atPath: directory + "/.env", contents: data)
    }

    static func createSourcesDirectory() throws {
        let directory = fileManager.currentDirectoryPath
        try fileManager.createDirectory(atPath: directory + "/Sources", withIntermediateDirectories: true)
    }

    static func createLibraryTarget(projectName: String) throws {
        let directory = fileManager.currentDirectoryPath
        let libraryDirectory = directory + "/Sources/\(projectName)"
        let librarySourceFile = libraryDirectory + "/" + projectName + ".swift"
        try fileManager.createDirectory(atPath: libraryDirectory, withIntermediateDirectories: true)
        try fileManager.createFile(atPath: librarySourceFile, contents: try DataFactory.makeLibraryFileData(), replace: false)
    }

    static func createExecutableTarget(projectName: String, executableName: String) throws {
        let directory = fileManager.currentDirectoryPath
        try fileManager.createDirectory(atPath: directory + "/Sources/\(executableName)", withIntermediateDirectories: true)
        fileManager.createFile(atPath: directory + "/Sources/\(executableName)/main.swift", contents: try DataFactory.makeExecutableFileData(projectName: projectName))
    }

    static func createPackageFile(projectName: String) throws {
        let directory = fileManager.currentDirectoryPath
        let path = directory + "/Package.swift"
        let data = try DataFactory.makePackageFileData(projectName: projectName)
        fileManager.createFile(atPath: path, contents: data)
    }

    static func createGodotProjectFile(projectName: String) throws {
        let directory = fileManager.currentDirectoryPath
        let path = directory + "/godot/project.godot"
        let data = try DataFactory.makeGodotProjectFileData(projectName: projectName)
        fileManager.createFile(atPath: path, contents: data)
    }

    static func createGDExtensionFile(projectName: String) throws {
        let directory = fileManager.currentDirectoryPath
        let path = directory + "/godot/\(projectName).gdextension"
        let data = try DataFactory.makeGDExtensionFileData(projectName: projectName)
        fileManager.createFile(atPath: path, contents: data)
    }

    static func createExportPresetsFile(projectName: String) throws {
        let directory = fileManager.currentDirectoryPath
        let data = try DataFactory.makeExportPresetsFileData(projectName: projectName)
        let path = directory + "/godot/export_presets.cfg"
        fileManager.createFile(atPath: path, contents: data)
    }

    static func copyMakefile() throws {
        guard let url = Bundle.module.url(forResource: "Makefile", withExtension: nil) else {
            throw Error.badURL
        }
        let directory = fileManager.currentDirectoryPath
        let destinationPath = directory + "/Makefile"
        try fileManager.copyItem(atPath: url.path, toPath: destinationPath)
    }

    static func copyGDDFile() throws {
        guard let url = Bundle.module.url(forResource: "GDD.md", withExtension: nil) else {
            throw Error.badURL
        }
        let directory = fileManager.currentDirectoryPath
        let destinationPath = directory + "/GDD.md"
        try fileManager.copyItem(atPath: url.path, toPath: destinationPath)
    }

    static func copyGitIgnoreFile() throws {
        guard let url = Bundle.module.url(forResource: ".gitignore", withExtension: nil) else {
            throw Error.badURL
        }
        let directory = fileManager.currentDirectoryPath
        let destinationPath = directory + "/.gitignore"
        try fileManager.copyItem(atPath: url.path, toPath: destinationPath)
    }

    static func copyGodotDirectory() throws {
        guard let url = Bundle.module.url(forResource: "godot", withExtension: nil) else {
            throw Error.badURL
        }
        let directory = fileManager.currentDirectoryPath
        
        let destinationPath = directory + "/godot"
        try fileManager.copyItem(atPath: url.path, toPath: destinationPath)
    }

    static func copyReadmeFile() throws {
        guard let url = Bundle.module.url(forResource: "README.md", withExtension: nil) else {
            throw Error.badURL
        }
        let directory = fileManager.currentDirectoryPath
        let destinationPath = directory + "/README.md"
        try fileManager.copyItem(atPath: url.path, toPath: destinationPath)
    }
}