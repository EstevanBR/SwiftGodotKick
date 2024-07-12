import Foundation

enum DataFactory {
    private enum Error: Swift.Error, LocalizedError {
        case noData
    }

    static func makeEnvFileData(projectName: String, godotPath: String) throws -> Data {
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

    static func makePackageFileData(projectName: String) throws -> Data {
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

    static func makeLibraryFileData() throws -> Data {
        guard let data = """
        import SwiftGodot

        #warning("Remove this HelloWorld class")
        @Godot(.tool)
        public class HelloWorld: Node {
            public override static func _ready() {
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

    static func makeExecutableFileData(projectName: String) throws -> Data {
        guard let data = """
        import \(projectName)
        import SwiftGodot
        import SwiftGodotKit

        static func loadScene (scene: SceneTree) {
            scene.root?.addChild(node: HelloWorld())
        }

        static func registerTypes (level: GDExtension.InitializationLevel) {
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

    static func makeGodotProjectFileData(projectName: String) throws -> Data {
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

    static func makeGDExtensionFileData(projectName: String) throws -> Data {
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

    static func makeExportPresetsFileData(projectName: String) throws -> Data {
        guard let data = """
        [preset.0]

        name="Packer"
        platform="Web"
        runnable=true
        dedicated_server=false
        custom_features=""
        export_filter="exclude"
        export_files=PackedStringArray("res://\(projectName).gdextension")
        include_filter=""
        exclude_filter=""
        export_path=""
        encryption_include_filters=""
        encryption_exclude_filters=""
        encrypt_pck=false
        encrypt_directory=false

        [preset.0.options]

        custom_template/debug=""
        custom_template/release=""
        variant/extensions_support=false
        vram_texture_compression/for_desktop=true
        vram_texture_compression/for_mobile=false
        html/export_icon=true
        html/custom_html_shell=""
        html/head_include=""
        html/canvas_resize_policy=2
        html/focus_canvas_on_start=true
        html/experimental_virtual_keyboard=false
        progressive_web_app/enabled=false
        progressive_web_app/offline_page=""
        progressive_web_app/display=1
        progressive_web_app/orientation=0
        progressive_web_app/icon_144x144=""
        progressive_web_app/icon_180x180=""
        progressive_web_app/icon_512x512=""
        progressive_web_app/background_color=Color(0, 0, 0, 1)
        """.data(using: .utf8) else { throw Error.noData }
        return data
    }
}
