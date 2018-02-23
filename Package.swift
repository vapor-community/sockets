// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Sockets",
    products: [
        .library(name: "TCP", targets: ["TCP"]),
    ],
    dependencies: [
        // ⏱ Promises and reactive-streams in Swift built for high-performance and scalability.
        .package(url: "https://github.com/vapor/async.git", from: "1.0.0-rc"),

        // 🌎 Utility package containing tools for byte manipulation, Codable, OS APIs, and debugging.
        .package(url: "https://github.com/vapor/core.git", from: "3.0.0-rc"),
    ],
    targets: [
        .target(name: "TCP", dependencies: ["Async", "Bits", "COperatingSystem", "Debugging"]),
        .testTarget(name: "TCPTests", dependencies: ["Async", "TCP"]),
    ]
)
