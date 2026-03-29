// swift-tools-version: 5.9
// Note: The primary way to build this app is via iOSAI.xcodeproj in Xcode.
// This Package.swift is provided for tooling compatibility only.
// FoundationModels requires iOS 26.0+.

import PackageDescription

let package = Package(
    name: "iOSAI",
    platforms: [
        .iOS(.v26)
    ],
    products: [
        .executable(
            name: "iOSAI",
            targets: ["iOSAI"]
        ),
    ],
    targets: [
        .executableTarget(
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
