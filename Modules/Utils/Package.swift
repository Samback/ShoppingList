// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Utils",
    platforms: [.iOS(.v16)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Utils",
            targets: ["Utils"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture",
                 from: "1.2.0"),
        .package(path: "../Models"),
        .package(url: "https://github.com/pointfreeco/swift-nonempty.git", from: "0.3.0"),
        .package(url: "https://github.com/pointfreeco/swift-validated", from: "0.2.1"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0")
    ],

    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Utils",
            dependencies: [
                .product(name: "ComposableArchitecture",
                         package: "swift-composable-architecture"),
               "Models",
                .product(name: "NonEmpty",
                            package: "swift-nonempty"),

                .product(name: "Validated",
                            package: "swift-validated"),
                .product(name: "Dependencies", package: "swift-dependencies"),
            ]),
        .testTarget(
            name: "UtilsTests",
            dependencies: ["Utils"])
    ]
)
