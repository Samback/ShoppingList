// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PurchaseList",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PurchaseList",
            targets: ["PurchaseList"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture",
                 from: "1.3.0"),
        .package(path: "../Note"),
        .package(path: "../Theme"),
        .package(path: "../Utils"),
        .package(path: "../Models"),
        .package(path: "../Scanner"),
        .package(path: "../Analytics"),
        .package(path: "../Tips"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
        .package(url: "https://github.com/siteline/swiftui-introspect", from: "1.0.0"),
        .package(url: "https://github.com/krzysztofzablocki/Inject.git", from: "1.0.5"),
        .package(url: "https://github.com/oliverfoggin/swift-composable-analytics", from: "1.0.0")
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
                "Analytics",
                "Tips",
                "Theme",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "SwiftUIIntrospect", package: "swiftui-introspect"),
                .product(name: "ComposableAnalytics", package: "swift-composable-analytics"),
                .product(name: "Inject", package: "Inject")
            ]

        ),
        .testTarget(
            name: "PurchaseListTests",
            dependencies: ["PurchaseList"])
    ]
)
