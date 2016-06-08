import PackageDescription

let package = Package(
    name: "Socks",
    targets: [
    	Target(name: "SocksCore"),
	Target(name: "Socks", dependencies: [.Target(name: "SocksCore")]),
        Target(name: "SocksCoreExampleTCPServer", dependencies: [.Target(name: "SocksCore")]),
        Target(name: "SocksCoreExampleTCPKeepAliveServer", dependencies: [.Target(name: "Socks")]),
    	Target(name: "SocksCoreExampleTCPClient", dependencies: [.Target(name: "SocksCore")]),
    	Target(name: "SocksExampleTCPServer", dependencies: [.Target(name: "Socks")]),
    	Target(name: "SocksExampleTCPClient", dependencies: [.Target(name: "Socks")]),
    	Target(name: "SocksExampleUDPClient", dependencies: [.Target(name: "Socks")]),
    	Target(name: "SocksExampleUDPServer", dependencies: [.Target(name: "Socks")]),
    ]
)
