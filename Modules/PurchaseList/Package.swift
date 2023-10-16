// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PurchaseList",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PurchaseList",
            targets: ["PurchaseList"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture",
                 from: "1.2.0"),
        .package(path: "../Note"),
        .package(path: "../Utils"),
        .package(path: "../Models"),
        .package(path: "../Scanner"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0")
    ],

    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "PurchaseList",
            dependencies: [
                .product(name: "ComposableArchitecture",
                         package: "swift-composable-architecture"),
                "Note",
                "Utils",
                "Models",
                "Scanner",
                .product(name: "Dependencies", package: "swift-dependencies")
            ]

        ),
        .testTarget(
            name: "PurchaseListTests",
            dependencies: ["PurchaseList"])
    ]
)
