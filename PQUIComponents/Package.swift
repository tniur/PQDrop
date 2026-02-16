// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "PQUIComponents",
    defaultLocalization: "ru",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PQUIComponents",
            targets: ["PQUIComponents"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.63.2"),
        .package(url: "https://github.com/SwiftGen/SwiftGenPlugin", exact: "6.6.2")
    ],
    targets: [
        .target(
            name: "PQUIComponents",
            exclude: [
                "../../swiftgen.yml"
            ],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins"),
                .plugin(name: "SwiftGenPlugin", package: "SwiftGenPlugin")
            ]
        ),

    ]
)
