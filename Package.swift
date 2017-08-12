// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Sockets",
    products: [
        .library(name: "Transport", targets: ["Transport"]),
        .library(name: "Sockets", targets: ["Sockets"]),
    ],
    dependencies: [
        // Core extensions, type-aliases, and functions that facilitate common tasks.
        .package(url: "https://github.com/vapor/core.git", .branch("beta")),
    ],
    targets: [
        .target(name: "Transport", dependencies: ["Core"]),
        .target(name: "Sockets", dependencies: ["Transport"]),
        .testTarget(name: "SocketsTests", dependencies: ["Sockets"]),
    ]
)
