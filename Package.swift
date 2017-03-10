import PackageDescription

let package = Package(
    name: "Socks",
    dependencies: [
        .Package(url: "https://github.com/vapor/bits.git", majorVersion: 0),
    ]
)
