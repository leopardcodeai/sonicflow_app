// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "FlowTonesCore",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "FlowTonesCore",
            targets: ["FlowTonesCore"]
        )
    ],
    targets: [
        .target(
            name: "FlowTonesCore"
        ),
        .testTarget(
            name: "FlowTonesCoreTests",
            dependencies: ["FlowTonesCore"]
        )
    ]
)
