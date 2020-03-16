// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CommonMarkAttributedString",
    platforms: [
        // specify each minimum deployment requirement,
        //otherwise the platform default minimum is used.
       .iOS(.v10),
       .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "CommonMarkAttributedString",
            targets: ["CommonMarkAttributedString"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftDocOrg/CommonMark.git", from: "0.2.2"),
    ],
    targets: [
        .target(
            name: "CommonMarkAttributedString",
            dependencies: ["CommonMark"]),
        .testTarget(
            name: "CommonMarkAttributedStringTests",
            dependencies: ["CommonMarkAttributedString"]),
    ]
)
