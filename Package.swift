// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Saboteur",
    platforms: [
        .iOS(.v16),
    ],
    products: [],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log", from: "1.5.0"),
    ],
    targets: []
)
