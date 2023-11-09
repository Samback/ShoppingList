// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ListManager",
    platforms: [
        .iOS(.v17)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ListManager",
            targets: ["ListManager"])
    ],

    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture",
                 from: "1.3.0"),
        .package(url: "https://github.com/c-villain/SwipeActions", from: "0.1.0"),
        .package(path: "../PurchaseList"),
        .package(path: "../Utils"),
        .package(path: "../Emojis"),
        .package(path: "../Theme")
    ],

    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ListManager",
            dependencies: [
                .product(name: "ComposableArchitecture",
                         package: "swift-composable-architecture"),
                .product(name: "SwipeActions",
                         package: "SwipeActions"),
                "PurchaseList",
                "Utils",
                "Theme",
                "Emojis"
            ]),
        .testTarget(
            name: "ListManagerTests",
            dependencies: ["ListManager"])
    ]
)
