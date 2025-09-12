// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "vibehack1",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(url: "https://github.com/airbnb/lottie-ios.git", from: "4.3.0")
    ],
    targets: [
        .target(
            name: "vibehack1",
            dependencies: [
                .product(name: "Lottie", package: "lottie-ios")
            ]
        )
    ]
)