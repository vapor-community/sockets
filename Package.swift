// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Sockets",
    products: [
        .library(name: "TCP", targets: ["TCP"]),
    ],
    dependencies: [
        // Swift Promises, Futures, and Streams.
        .package(url: "https://github.com/vapor/async.git", .branch("stream-refactor")),

        // Core extensions, type-aliases, and functions that facilitate common tasks.
        .package(url: "https://github.com/vapor/core.git", .branch("stream-refactor")),
    ],
    targets: [
        .target(name: "TCP", dependencies: ["Async", "Bits", "COperatingSystem", "Debugging"]),
        .testTarget(name: "TCPTests", dependencies: ["Async", "TCP"]),
    ]
)
