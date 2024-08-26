// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftNet",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "SwiftNet",
            targets: ["SwiftNet"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SwiftNet",
            dependencies:[]),
    ]
)
