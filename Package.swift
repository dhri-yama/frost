// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Frost",
    platforms: [.macOS(.v13)],
    targets: [
        .target(name: "FrostCore", path: "Sources/FrostCore"),
        .executableTarget(name: "Frost", dependencies: ["FrostCore"], path: "Sources/Frost"),
        .testTarget(name: "FrostTests", dependencies: ["FrostCore"], path: "Tests/FrostTests"),
    ]
)
