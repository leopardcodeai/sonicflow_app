// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SonicFlowCore",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "SonicFlowCore",
            targets: ["SonicFlowCore"]
        )
    ],
    targets: [
        .target(
            name: "SonicFlowCore"
        ),
        .testTarget(
            name: "SonicFlowCoreTests",
            dependencies: ["SonicFlowCore"]
        )
    ]
)
