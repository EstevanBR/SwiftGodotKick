`SwiftGodotKick` is a program that creates the start of a SwiftGodot + SwiftGodotKit project.

### Initial setup
Just run this:
```
$ swift run CreateProject
```

and follow the prompts.

IMPORTANT:

When it asks which directory, this is the directory that your project folder will be created in, so it's asking for the parent directory of your project. I may change this later. for example `swift package init` will put the `Package.swift` file in the current working directory, but this tool will create a folder first.

### Example output
```
$ swift run CreateProject

Please enter where you would like the project directory to be created: ../
Please enter the name of the project: MySwiftGodotKickProject
Created /home/user/Documents/Code/MySwiftGodotKickProject/Package.swift
Created /home/user/Documents/Code/MySwiftGodotKickProject/README.md
Created /home/user/Documents/Code/MySwiftGodotKickProject/.gitignore
Created /home/user/Documents/Code/MySwiftGodotKickProject/.env
Created /home/user/Documents/Code/MySwiftGodotKickProject/Sources
Created /home/user/Documents/Code/MySwiftGodotKickProject/Sources/MySwiftGodotKickProject/MySwiftGodotKickProject.swift
Created /home/user/Documents/Code/MySwiftGodotKickProject/Sources/MySwiftGodotKickProjectGame/main.swift
Created /home/user/Documents/Code/MySwiftGodotKickProject/GDD.md
Created /home/user/Documents/Code/MySwiftGodotKickProject/godot
Created /home/user/Documents/Code/MySwiftGodotKickProject/godot/project.godot
Created /home/user/Documents/Code/MySwiftGodotKickProject/godot/MySwiftGodotKickProject.gdextension
Created /home/user/Documents/Code/MySwiftGodotKickProject/godot/export_presets.cfg
Created /home/user/Documents/Code/MySwiftGodotKickProject/Makefile
run the following command:

cd /home/user/Documents/Code/MySwiftGodotKickProject && make all
```

This will create a project with this structure:
```
├── .env
├── GDD.md
├── godot
│   ├── bin
│   │   └── .gdignore
│   ├── export_presets.cfg
│   ├── exports
│   │   └── .gdignore
│   ├── .gitignore
│   ├── icon.svg
│   ├── MySwiftGodotKickProject.gdextension
│   └── project.godot
├── Makefile
├── Package.resolved
├── Package.swift
├── README.md
└── Sources
    ├── MySwiftGodotKickProject
    │   └── MySwiftGodotKickProject.swift
    └── MySwiftGodotKickProjectGame
        ├── main.swift
        └── Resources
            └── MySwiftGodotKickProject.pck
```

### Using resources:
As long as we import all our resources into Godot, we can reference them in Swift using the same `res://` paths as you would in GDScript by exporting the Resource .pck file, and passing it to Godot when we run Godot using SwiftGodotKit.

The `godot/export_presets.cfg` file is used by `make pack` to create the `Sources/MySwiftGodotKickProjectGame/Resources/MySwiftGodotKickProject.pck` resource pack.

IMPORTANT: You must have the export templates downloaded.

Ultimately, this allows both `.gdscript` and Swift code to access a resource like: `icon.svg` by using `res://icon.svg` by putting the `MySwiftGodotKickProject.pck` resource file in the `Resources/` folder of the Swift Package target, and declaring that Resource as a resource in the `Package.swift` manifest like so:
```swift
let package = Package(
    ...
    targets: [
        .executableTarget(
            name: "MySwiftGodotKickProjectGame",
            dependencies: [
                "MySwiftGodotKickProject",
                .product(name: "SwiftGodotKit", package: "SwiftGodotKit")
            ],
            resources: [
                .copy("Resources") // <-- here, MySwiftGodotKickProject.pck lives in this folder
            ]),
```
We are able to access the resource pack, and pass it to `runGodot`:
```swift
// Sources/MySwiftGodotKickProjectGame/main.swift

let packPath = Bundle.module.path(forResource: "MySwiftGodotKickProject", ofType: "pck")! // <-- here

runGodot(
    args: [
        "--main-pack", packPath // <-- and here
    ],
    initHook: registerTypes,
    loadScene: loadScene,
    loadProjectSettings: { settings in }
)
```

So we can do something like this:
```swift
// Icon2D.swift

let image = GD.load(path: "res://icon.svg") as! Texture2D
```
