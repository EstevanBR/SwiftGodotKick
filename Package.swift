// swift-tools-version: 5.9

// this file will be replaced by CreateProject

import PackageDescription

let package = Package(
    name: "SwiftGodotKitProjectCreator",
    products: [
        .executable(
            name: "CreateProject",
            targets: ["CreateProject"]),
    ],
    targets: [
        .executableTarget(
            name: "CreateProject",
            resources: [
                .copy("Resources")
            ]
        ),
    ]
)
