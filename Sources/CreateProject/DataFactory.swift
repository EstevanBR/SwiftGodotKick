import Foundation

enum DataFactory {
    static func makeEnvFileData(projectName: String, executableName: String, godotPath: String) throws -> Data {
        try
        """
        export PROJECT_NAME=\(projectName)
        export GODOT=\(godotPath)
        export GODOT_PROJECT_DIRECTORY=\(FileManager().currentDirectoryPath + "/godot")
        export GODOT_PROJECT_FILE_PATH=$(GODOT_PROJECT_DIRECTORY)/project.godot
        export GODOT_BIN_PATH=$(GODOT_PROJECT_DIRECTORY)/bin
        export BUILD_PATH=./.build
        export LIBRARY_NAME=$(PROJECT_NAME)
        export EXECUTABLE_NAME=\(executableName)

        """
        .utf8Data
    }

    static func makePackageFileData(projectName: String, executableName: String) throws -> Data {
        try
        """
        // swift-tools-version: 5.9

        import PackageDescription

        let package = Package(
            name: "\(projectName)",
            platforms: [.macOS(.v13)],
            products: [
                .executable(
                    name: "\(executableName)",
                    targets: ["\(executableName)"]),
                .library(
                    name: "\(projectName)",
                    type: .dynamic,
                    targets: ["\(projectName)"]),
            ],
            dependencies: [
                .package(url: "https://github.com/migueldeicaza/SwiftGodot", revision: "20d2d7a35d2ad392ec556219ea004da14ab7c1d4"),
                .package(url: "https://github.com/migueldeicaza/SwiftGodotKit", revision: "7d7edf2f7701ef0328aece07399ba878241c62f0")
            ],
            targets: [
                .executableTarget(
                    name: "\(executableName)",
                    dependencies: [
                        "\(projectName)",
                        .product(name: "SwiftGodotKit", package: "SwiftGodotKit")
                    ],
                    resources: [
                        .copy("Resources")
                    ]),
                .target(
                    name: "\(projectName)",
                    dependencies: [
                        .product(name: "SwiftGodot", package: "SwiftGodot")
                    ]),
            ]
        )

        """
        .utf8Data
    }

    static func makeLibraryFileData() throws -> Data {
        try
        """
        import SwiftGodot

        #warning("Remove this Icon2D class")
        @Godot(.tool)
        public class Icon2D: Sprite2D {
            public override func _ready() {
                GD.printDebug("Hello world!")
                guard let image = GD.load(path: "res://icon.svg") as? Texture2D else {
                    fatalError("Could not load res://icon.svg")
                }

                texture = image
                scale = .init(x: 0.25, y: 0.25)
            }

            public override func _process(delta: Double) {
                rotate(radians: delta)
            }
        }

        public let godotTypes: [Wrapped.Type] = [
            Icon2D.self
        ]

        #initSwiftExtension(cdecl: "swift_entry_point", types: godotTypes)

        """
        .utf8Data
    }

    static func makeMainFileData(projectName: String) throws -> Data {
        try
        """
        import Foundation
        import SwiftGodot
        import SwiftGodotKit
        import \(projectName)

        guard let packPath = Bundle.module.path(forResource: "\(projectName)", ofType: "pck") else {
            fatalError("Could not load Pack")
        }

        func loadScene (scene: SceneTree) {
            scene.root?.addChild(node: Icon2D())
        }

        func registerTypes (level: GDExtension.InitializationLevel) {
            switch level {
            case .scene:
                #warning("uncomment this line if type casting / lookups don't work")
                // \(projectName).godotTypes.forEach { register(type: $0) }
                break
            default:
                break
            }
        }

        runGodot(
            args: [
                "--main-pack", packPath
            ],
            initHook: registerTypes,
            loadScene: loadScene,
            loadProjectSettings: { settings in }
        )

        """
        .utf8Data
    }

    static func makeGodotProjectFileData(projectName: String) throws -> Data {
        try
        """
        ; Engine configuration file.
        ; It's best edited using the editor UI and not directly,
        ; since the parameters that go here are not all obvious.
        ;
        ; Format:
        ;   [section] ; section goes between []
        ;   param=value ; assign values to parameters

        config_version=5

        [application]

        config/name="\(projectName)"
        config/features=PackedStringArray("\(godotVersion)")
        
        """
        .utf8Data
    }

    static func makeGDExtensionFileData(projectName: String) throws -> Data {
        try
        """
        [configuration]
        entry_symbol = "swift_entry_point"
        compatibility_minimum = \(godotVersion)

        [libraries]
        # web is not actually functional but required to use a Web export template when creating the .pck file via `make pack`
        web.debug = "res://bin/lib\(projectName).\(dynamicExtension)"
        web.release = "res://bin/lib\(projectName).\(dynamicExtension)"

        macos.debug = "res://bin/lib\(projectName).\(dynamicExtension)"
        macos.release = "res://bin/lib\(projectName).\(dynamicExtension)"
        windows.debug.x86_32 = "res://bin/lib\(projectName).\(dynamicExtension)"
        windows.release.x86_32 = "res://bin/lib\(projectName).\(dynamicExtension)"
        windows.debug.x86_64 = "res://bin/lib\(projectName).\(dynamicExtension)"
        windows.release.x86_64 = "res://bin/lib\(projectName).\(dynamicExtension)"
        linux.debug.x86_64 = "res://bin/lib\(projectName).\(dynamicExtension)"
        linux.release.x86_64 = "res://bin/lib\(projectName).\(dynamicExtension)"
        linux.debug.arm64 = "res://bin/lib\(projectName).\(dynamicExtension)"
        linux.release.arm64 = "res://bin/lib\(projectName).\(dynamicExtension)"
        linux.debug.rv64 = "res://bin/lib\(projectName).\(dynamicExtension)"
        linux.release.rv64 = "res://bin/lib\(projectName).\(dynamicExtension)"
        android.debug.x86_64 = "res://bin/lib\(projectName).\(dynamicExtension)"
        android.release.x86_64 = "res://bin/lib\(projectName).\(dynamicExtension)"
        android.debug.arm64 = "res://bin/lib\(projectName).\(dynamicExtension)"
        android.release.arm64 = "res://bin/lib\(projectName).\(dynamicExtension)"
        
        """
        .utf8Data
    }

    static func makeExportPresetsFileData(projectName: String) throws -> Data {
        try
        """
        [preset.0]

        name="Packer"
        platform="Web"
        runnable=true
        dedicated_server=false
        custom_features=""
        export_filter="all_resources"
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
        """
        .utf8Data
    }

    static func makeMakefile(projectName: String) throws -> Data {
        try """
        include .env

        .PHONY: all
        all: paths build deploy pack

        .PHONY: paths
        paths:
        	@echo "Path to Godot executable:\\n\\t$(GODOT)"
        	@echo "Godot bin/ path:\\n\\t$(GODOT_BIN_PATH)"
        	@echo "Build path:\\n\\t$(BUILD_PATH)"
        	@echo "Godot version:\\n\\t`$(GODOT) --version`"
        	@echo "Library name:\\n\\t$(LIBRARY_NAME)"
        	@echo "Executable name:\\n\\t$(EXECUTABLE_NAME)"
        	@echo "Godot project file path:\\n\\t$(GODOT_PROJECT_FILE_PATH)"

        .PHONY: build
        build:
        	mkdir -p $(BUILD_PATH)
        	swift build --product $(LIBRARY_NAME) --build-path $(BUILD_PATH)
        	swift build --product $(EXECUTABLE_NAME) --build-path $(BUILD_PATH)

        .PHONY: deploy
        deploy:
        	rm -rf $(GODOT_BIN_PATH)
        	mkdir -p $(GODOT_BIN_PATH)

        	cp $(BUILD_PATH)/debug/libSwiftGodot.\(dynamicExtension) $(GODOT_BIN_PATH)
        	cp $(BUILD_PATH)/debug/lib\(projectName).\(dynamicExtension) $(GODOT_BIN_PATH)

        .PHONY: run
        run:
        	swift run $(EXECUTABLE_NAME) --build-path $(BUILD_PATH)

        .PHONY: open
        open:
        	$(GODOT) $(GODOT_PROJECT_FILE_PATH)

        .PHONY: pack
        pack:
        	@echo "Going to open Godot to ensure all resources are imported."
        	-$(GODOT) $(GODOT_PROJECT_FILE_PATH) --headless --quit
        	@echo "Exporting the .pck file"
        	$(GODOT) --headless --path $(GODOT_PROJECT_DIRECTORY) --export-pack Packer ../Sources/$(EXECUTABLE_NAME)/Resources/$(LIBRARY_NAME).pck

        """
        .utf8Data
    }
}

// on macOS, dynamic libraries have the .dylib file extension, but on other platforms it's .so
private var dynamicExtension: String {
    #if os(macOS)
    "dylib"
    #else
    "so"
    #endif
}

private extension String {
    private enum Error: Swift.Error, LocalizedError {
        case noData

        var errorDescription: String? {
            "Could not get utf8 data from string"
        }
    }

    var utf8Data: Data {
        get throws {
            guard let data = self.data(using: .utf8) else { throw Error.noData }
            return data
        }
    }
}