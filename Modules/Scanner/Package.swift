// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Scanner",
    platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Scanner",
            targets: ["Scanner"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture",
                 from: "1.2.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Scanner",
            dependencies: [
                .product(name: "ComposableArchitecture",
                         package: "swift-composable-architecture")

            ]),
        .testTarget(
            name: "ScannerTests",
            dependencies: ["Scanner"])
    ]
)
