// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NotificationsHelper",
    platforms: [.iOS(.v10), .macOS(.v10_14), .watchOS(.v3)],
    products: [
        .library(
            name: "NotificationsHelper",
            targets: ["NotificationsHelper"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "NotificationsHelper",
            dependencies: []),
        .testTarget(
            name: "NotificationsHelperTests",
            dependencies: ["NotificationsHelper"]),
    ]
)
