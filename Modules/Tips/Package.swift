// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Tips",
    platforms: [.iOS(.v17)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Tips",
            targets: ["Tips"])
    ],
    dependencies: [
        .package(path: "../Theme"),
        .package(url: "https://github.com/krzysztofzablocki/Inject.git", from: "1.0.5")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Tips",
            dependencies: [
                "Theme",
                .product(name: "Inject", package: "Inject")
            ]
        ),
        .testTarget(
            name: "TipsTests",
            dependencies: ["Tips"])
    ]
)
