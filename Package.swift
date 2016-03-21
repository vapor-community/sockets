import PackageDescription

let package = Package(
    name: "Socks",
    targets: [
    	Target(name: "SocksCore"),
	Target(name: "Socks", dependencies: [.Target(name: "SocksCore")]),
    	Target(name: "SocksCoreExampleServer", dependencies: [.Target(name: "SocksCore")]),
    	Target(name: "SocksCoreExampleClient", dependencies: [.Target(name: "SocksCore")]),
    	Target(name: "SocksExampleServer", dependencies: [.Target(name: "Socks")]),
    	Target(name: "SocksExampleClient", dependencies: [.Target(name: "Socks")]),
    ]
)
