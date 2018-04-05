// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Stimpak",
    products: [
        .library(
            name: "Stimpak",
            targets: ["Stimpak"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Stimpak",
            dependencies: []),
        .testTarget(
            name: "StimpakTests",
            dependencies: ["Stimpak"]),
    ]
)
