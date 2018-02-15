// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Sockets",
    products: [
        .library(name: "TCP", targets: ["TCP"]),
    ],
    dependencies: [
        // Swift Promises, Futures, and Streams.
        .package(url: "https://github.com/vapor/async.git", "1.0.0-beta.1"..<"1.0.0-beta.2"),

        // Core extensions, type-aliases, and functions that facilitate common tasks.
        .package(url: "https://github.com/vapor/core.git", "3.0.0-beta.1"..<"3.0.0-beta.2"),
    ],
    targets: [
        .target(name: "TCP", dependencies: ["Async", "Bits", "COperatingSystem", "Debugging"]),
        .testTarget(name: "TCPTests", dependencies: ["Async", "TCP"]),
    ]
)
