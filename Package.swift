// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Endpoints",
    platforms: [
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "Endpoints",
            targets: ["Endpoints"]
        ),
    ],
    targets: [
        .target(name: "Endpoints"),
        .testTarget(
            name: "EndpointsTests",
            dependencies: ["Endpoints"],
            resources: [
                .process("Resources/gist.json"),
                .process("Resources/corrupt.json"),
                .process("Resources/mistype.json"),
                .process("Resources/success.json"),
            ]
        ),
    ]
)
