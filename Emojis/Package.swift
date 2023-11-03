// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Emojis",
    platforms: [.iOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Emojis",
            targets: ["Emojis"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture",
                 from: "1.3.0"),
        .package(path: "../Theme")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Emojis",
        dependencies: [
            .product(name: "ComposableArchitecture",
                     package: "swift-composable-architecture"),
            "Theme"

        ]),
        .testTarget(
            name: "EmojisTests",
            dependencies: ["Emojis"])
    ]
)
