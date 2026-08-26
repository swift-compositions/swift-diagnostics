// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-diagnostics",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(name: "Diagnostics", targets: ["Diagnostics"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-molecules/swift-diagnostic.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-source.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "Diagnostics",
            dependencies: [
                .product(name: "Diagnostic", package: "swift-diagnostic"),
                .product(name: "Source", package: "swift-source"),
            ]
        ),
        .testTarget(
            name: "Diagnostics Tests",
            dependencies: [
                "Diagnostics"
            ]
        ),
    ]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
