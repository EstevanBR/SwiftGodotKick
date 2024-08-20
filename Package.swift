// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SwiftGodotKick",
    platforms: [
        .macOS(.v13),
        .iOS (.v15)
    ],
    products: [
        .executable(
            name: "swift-godot-kick",
            targets: ["CreateProject"]),
    ],
    targets: [
        .executableTarget(
            name: "CreateProject",
            resources: [
                .copy("Resources")
            ]
        )
    ]
)
