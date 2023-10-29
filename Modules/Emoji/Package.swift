// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Emoji",
    platforms: [.iOS(.v16)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Emoji",
            targets: ["Emoji"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture",
                 from: "1.2.0"),
        .package(url: "https://github.com/Kelvas09/EmojiPicker.git", from: "1.0.0"),
        .package(url: "https://github.com/izyumkin/MCEmojiPicker", from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Emoji",
            dependencies: [
                .product(name: "ComposableArchitecture",
                         package: "swift-composable-architecture")
                ,
                .product(name: "EmojiPicker", package: "EmojiPicker"),
                .product(name: "MCEmojiPicker", package: "MCEmojiPicker")
            ]),
        .testTarget(
            name: "EmojiTests",
            dependencies: ["Emoji"])
    ]
)
