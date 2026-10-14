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
        .package(
            url: "https://github.com/swift-atoms/swift-text.git",
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
                .target(name: "Diagnostics"),
                .product(name: "Source", package: "swift-source"),
                .product(name: "Text", package: "swift-text"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    target.swiftSettings = (target.swiftSettings ?? []) + [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableExperimentalFeature("Lifetimes"),
        .treatAllWarnings(as: .error),
    ]
}
