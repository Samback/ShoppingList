// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Scanner",
    platforms: [.iOS(.v17)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Scanner",
            targets: ["Scanner"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture",
                 from: "1.3.0"),
        .package(url: "https://github.com/exyte/ExyteMediaPicker.git", from: "1.0.0"),
        .package(url: "https://github.com/alobaili/camera-picker", from: "0.0.1"),
        .package(url: "https://github.com/ZaidPathan/ZImageCropper", branch: "master"),
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.0.1")),
        .package(path: "../Theme")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Scanner",
            dependencies: [
                .product(name: "ComposableArchitecture",
                         package: "swift-composable-architecture"),
                .product(name: "ExyteMediaPicker", package: "ExyteMediaPicker"),
                .product(name: "CameraPicker", package: "camera-picker"),
                .product(name: "ZImageCropper", package: "ZImageCropper"),
                .product(name: "SnapKit", package: "SnapKit"),
                "Theme"
            ]),
        .testTarget(
            name: "ScannerTests",
            dependencies: ["Scanner"])
    ]
)
