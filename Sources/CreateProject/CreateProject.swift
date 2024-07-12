import Foundation

private enum Error: Swift.Error, LocalizedError {
    case noData
    case missingUserChoice
    case invalidProjectPath
    case badURL
}

let fileManager = FileManager()

@main
private struct CreateProject {
    static func main() throws {
        let projectPath = try getUserChoice(message: "Where would you like this project to be created?: ")
        do {
            try createProjectDirectory(atPath: projectPath)
        } catch {
            print("Could not create project directory due to error: \(error.localizedDescription)")
            throw error
        }

        guard fileManager.changeCurrentDirectoryPath(projectPath) else { throw Error.invalidProjectPath }

        print("pwd: " + fileManager.currentDirectoryPath)

        let projectName = try getUserChoice(message: "Please enter your project name: ")
        
        let godotPath: String = switch ProcessInfo.processInfo.environment["GODOT"] {
            case .some(let value): value
            case .none: try getUserChoice(message: "Please enter the full path to the Godot 4.2 executable: ")
        }
        
        try createProjectDirectory(atPath: projectPath)
        try createEnvFile(projectName: projectName, godotPath: godotPath)
        try createSourcesDirectory()
        try createLibraryTarget(projectName: projectName)

        let executableName = projectName + "Game"
        try createExecutableTarget(projectName: projectName, executableName: executableName)
        try createPackageFile(projectName: projectName)

        try copyMakefile()
        try copyGDDFile()
        try copyGitIgnoreFile()
        try copyGodotDirectory()
        try createGodotProjectFile(projectName: projectName)
        try createGDExtensionFile(projectName: projectName)
    }
}

private func getUserChoice(message: String) throws -> String {
    print(message, terminator: "")
    guard let choice = readLine(strippingNewline: true) else {
        throw Error.missingUserChoice
    }
    return choice
}

private func createProjectDirectory(atPath path: String) throws {
    try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true)
}

private func makeEnvFileData(projectName: String, godotPath: String) throws -> Data {
    let directory = fileManager.currentDirectoryPath
    let godotProjectDirectory = directory + "/godot"
    guard let data = """
    export PROJECT_NAME=\(projectName)
    export GODOT=\(godotPath)
    export GODOT_PROJECT_DIRECTORY=\(godotProjectDirectory)
    export GODOT_PROJECT_FILE_PATH=$(GODOT_PROJECT_DIRECTORY)/project.godot
    export GODOT_BIN_PATH=$(GODOT_PROJECT_DIRECTORY)/bin
    export BUILD_PATH=./build
    export LIBRARY_NAME=$(PROJECT_NAME)
    export EXECUTABLE_NAME=$(PROJECT_NAME)Game

    """.data(using: .utf8) else { throw Error.noData }
    return data
}

private func createEnvFile(projectName: String, godotPath: String) throws {
    let directory = fileManager.currentDirectoryPath
    let data = try makeEnvFileData(projectName: projectName, godotPath: godotPath)
    fileManager.createFile(atPath: directory + "/.env", contents: data)
}

private func createSourcesDirectory() throws {
    let directory = fileManager.currentDirectoryPath
    try fileManager.createDirectory(atPath: directory + "/Sources", withIntermediateDirectories: true)
}

private func createLibraryTarget(projectName: String) throws {
    let directory = fileManager.currentDirectoryPath
    let libraryDirectory = directory + "/Sources/\(projectName)"
    let librarySourceFile = libraryDirectory + "/" + projectName + ".swift"
    try fileManager.createDirectory(atPath: libraryDirectory, withIntermediateDirectories: true)
    try fileManager.createFile(atPath: librarySourceFile, contents: try makeLibraryFileData(), replace: false)
}

private func createExecutableTarget(projectName: String, executableName: String) throws {
    let directory = fileManager.currentDirectoryPath
    try fileManager.createDirectory(atPath: directory + "/Sources/\(executableName)", withIntermediateDirectories: true)
    fileManager.createFile(atPath: directory + "/Sources/\(executableName)/main.swift", contents: try makeExecutableFileData(projectName: projectName))
}

private func createPackageFile(projectName: String) throws {
    let directory = fileManager.currentDirectoryPath
    let path = directory + "/Package.swift"
    let data = try makePackageFileData(projectName: projectName)
    fileManager.createFile(atPath: path, contents: data)
}

private func createGodotProjectFile(projectName: String) throws {
    let directory = fileManager.currentDirectoryPath
    let path = directory + "/godot/project.godot"
    let data = try makeGodotProjectFileData(projectName: projectName)
    fileManager.createFile(atPath: path, contents: data)
}

private func createGDExtensionFile(projectName: String) throws {
    let directory = fileManager.currentDirectoryPath
    let path = directory + "/godot/\(projectName).gdextension"
    let data = try makeGDExtensionFileData(projectName: projectName)
    fileManager.createFile(atPath: path, contents: data)
}

private func makePackageFileData(projectName: String) throws -> Data {
    guard let data = """
    // swift-tools-version: 5.9

    import PackageDescription

    let package = Package(
        name: "\(projectName)",
        products: [
            .executable(
                name: "\(projectName)Game",
                targets: ["\(projectName)Game"]),
            .library(
                name: "\(projectName)",
                type: .dynamic,
                targets: ["\(projectName)"]),
        ],
        dependencies: [
            .package(url: "https://github.com/EstevanBR/SwiftGodot", branch: "estevanBR"),
            .package(url: "https://github.com/EstevanBR/SwiftGodotKit", branch: "estevanBR")
        ],
        targets: [
            .executableTarget(
                name: "\(projectName)Game",
                dependencies: [
                    "\(projectName)",
                    .product(name: "SwiftGodotKit", package: "SwiftGodotKit")
                ]),
            .target(
                name: "\(projectName)",
                dependencies: [
                    .product(name: "SwiftGodot", package: "SwiftGodot")
                ]),
        ]
    )

    """.data(using: .utf8) else { throw Error.noData }
    return data
}

private func makeLibraryFileData() throws -> Data {
    guard let data = """
    import SwiftGodot

    #warning("Remove this HelloWorld class")
    @Godot(.tool)
    public class HelloWorld: Node {
        public override func _ready() {
            GD.printDebug("Hello world!")
        }
    }

    public let godotTypes: [Wrapped.Type] = [
        HelloWorld.self
    ]

    #initSwiftExtension(cdecl: "swift_entry_point", types: godotTypes)

    """.data(using: .utf8) else { throw Error.noData }
    return data
}

private func makeExecutableFileData(projectName: String) throws -> Data {
    guard let data = """
    import \(projectName)
    import SwiftGodot
    import SwiftGodotKit

    func loadScene (scene: SceneTree) {
        scene.root?.addChild(node: HelloWorld())
    }

    func registerTypes (level: GDExtension.InitializationLevel) {
        switch level {
        case .scene:
            \(projectName).godotTypes.forEach { register(type: $0) }
        default:
            break
        }
    }

    print("א")

    runGodot(
        args: [],
        initHook: registerTypes,
        loadScene: loadScene,
        loadProjectSettings: { settings in }
    )

    """.data(using: .utf8) else { throw Error.noData }
    return data
}

private func makeGodotProjectFileData(projectName: String) throws -> Data {
    guard let data = """
    ; Engine configuration file.
    ; It's best edited using the editor UI and not directly,
    ; since the parameters that go here are not all obvious.
    ;
    ; Format:
    ;   [section] ; section goes between []
    ;   param=value ; assign values to parameters

    config_version=5

    [application]

    config/name="Example22"
    config/features=PackedStringArray("4.2")
    
    """.data(using: .utf8) else { throw Error.noData }
    return data
}

private func makeGDExtensionFileData(projectName: String) throws -> Data {
    guard let data = """
    [configuration]
    entry_symbol = "swift_entry_point"
    compatibility_minimum = 4.2

    [libraries]
    macos.debug = "res://bin/lib\(projectName).so"
    macos.release = "res://bin/lib\(projectName).so"
    windows.debug.x86_32 = "res://bin/lib\(projectName).so"
    windows.release.x86_32 = "res://bin/lib\(projectName).so"
    windows.debug.x86_64 = "res://bin/lib\(projectName).so"
    windows.release.x86_64 = "res://bin/lib\(projectName).so"
    linux.debug.x86_64 = "res://bin/lib\(projectName).so"
    linux.release.x86_64 = "res://bin/lib\(projectName).so"
    linux.debug.arm64 = "res://bin/lib\(projectName).so"
    linux.release.arm64 = "res://bin/lib\(projectName).so"
    linux.debug.rv64 = "res://bin/lib\(projectName).so"
    linux.release.rv64 = "res://bin/lib\(projectName).so"
    android.debug.x86_64 = "res://bin/lib\(projectName).so"
    android.release.x86_64 = "res://bin/lib\(projectName).so"
    android.debug.arm64 = "res://bin/lib\(projectName).so"
    android.release.arm64 = "res://bin/lib\(projectName).so"
    
    """.data(using: .utf8) else { throw Error.noData }
    return data
}

func copyMakefile() throws {
    guard let url = Bundle.module.url(forResource: "Makefile", withExtension: nil) else {
        throw Error.badURL
    }
    let directory = fileManager.currentDirectoryPath
    let destinationPath = directory + "/Makefile"
    try fileManager.copyItem(atPath: url.path, toPath: destinationPath)
}

func copyGDDFile() throws {
    guard let url = Bundle.module.url(forResource: "GDD.md", withExtension: nil) else {
        throw Error.badURL
    }
    let directory = fileManager.currentDirectoryPath
    let destinationPath = directory + "/GDD.md"
    try fileManager.copyItem(atPath: url.path, toPath: destinationPath)
}

func copyGitIgnoreFile() throws {
    guard let url = Bundle.module.url(forResource: ".gitignore", withExtension: nil) else {
        throw Error.badURL
    }
    let directory = fileManager.currentDirectoryPath
    let destinationPath = directory + "/.gitignore"
    try fileManager.copyItem(atPath: url.path, toPath: destinationPath)
}

func copyGodotDirectory() throws {
    guard let url = Bundle.module.url(forResource: "godot", withExtension: nil) else {
        throw Error.badURL
    }
    let directory = fileManager.currentDirectoryPath
    
    let destinationPath = directory + "/godot"
    try fileManager.copyItem(atPath: url.path, toPath: destinationPath)
}

private extension FileManager {
    struct FileExistsError: Swift.Error {}

    func createFile(atPath path: String, contents data: Data, replace: Bool) throws {
        if replace == false, fileManager.fileExists(atPath: path) {
            throw FileExistsError()
        }
        createFile(atPath: path, contents: data)
    }
}