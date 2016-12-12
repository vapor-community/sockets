import PackageDescription

let package = Package(
    name: "Socks",
    targets: [
    	Target(name: "SocksCore"),
    	Target(name: "Socks", dependencies: ["SocksCore"]),
      //Target(name: "SocksCoreExampleTCPServer", dependencies: ["SocksCore"]),
      //Target(name: "SocksCoreExampleTCPKeepAliveServer", dependencies: ["Socks"]),
    	//Target(name: "SocksCoreExampleTCPClient", dependencies: ["SocksCore"]),
    	//Target(name: "SocksExampleTCPServer", dependencies: ["Socks"]),
    	//Target(name: "SocksExampleTCPClient", dependencies: ["Socks"]),
    	//Target(name: "SocksExampleUDPClient", dependencies: ["Socks"]),
    	//Target(name: "SocksExampleUDPServer", dependencies: ["Socks"]),
    ],
    dependencies: [
        // Core typealiases and extensions for working with Bytes.
        .Package(url: "https://github.com/vapor/core.git", majorVersion: 1),
    ],
    exclude: [
        "Sources/SocksCoreExampleTCPServer",
        "Sources/SocksCoreExampleTCPKeepAliveServer",
        "Sources/SocksCoreExampleTCPClient",
        "Sources/SocksExampleTCPServer",
        "Sources/SocksExampleTCPClient",
        "Sources/SocksExampleUDPClient",
        "Sources/SocksExampleUDPServer",
    ]
)
