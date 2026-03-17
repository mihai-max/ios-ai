// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "iOSAI",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "iOSAI",
            targets: ["iOSAI"]
        ),
    ],
    targets: [
        .target(
            name: "iOSAI",
            path: "iOSAI",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "iOSAITests",
            dependencies: ["iOSAI"],
            path: "iOSAITests"
        ),
    ]
)
