// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Objective_C",
    dependencies: [
        .package(path: "../MyCustomPackage")
    ],
    targets: [
        .target(
            name: "Objective_C",
            dependencies: ["MyCustomPackage"]
        ),
        .testTarget(name: "Objective_CTests", dependencies: ["Objective_C"]),
    ]
)
