// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "MyCustomPackage",
    products: [
        .library(
            name: "MyCustomPackage",
            targets: ["MyCustomPackage"]),
    ],
    targets: [
        .target(
            name: "MyCustomPackage",
            dependencies: []),
    ]
)

