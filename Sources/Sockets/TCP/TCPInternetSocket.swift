import libc

public typealias TCPDuplexProgram = TCPServer & TCPClient

public final class TCPInternetSocket: InternetSocket, TCPDuplexSocket, TCPDuplexProgram,  DuplexProgramStream {

    // stream
    public let hostname: String
    public let port: UInt16
    public let securityLayer: SecurityLayer

    // sockets
    public let address: ResolvedInternetAddress
    public private(set) var descriptor: Descriptor
    public let config: Config
    public private(set) var isClosed: Bool

    // MARK: Init

    public convenience init(
        hostname: String,
        port: UInt16,
        _ securityLayer: SecurityLayer = .none
    ) throws {
        let address = InternetAddress(
            hostname: hostname,
            port: port
        )
        try self.init(address, securityLayer)
    }

    public convenience init(
        _ address: InternetAddress,
        _ securityLayer: SecurityLayer = .none
    ) throws {
        var conf = Config.TCP(addressFamily: address.addressFamily)
        let resolved = try address.resolve(with: &conf)
        let descriptor = try Descriptor(conf)
        try self.init(
            descriptor,
            conf,
            resolved,
            securityLayer
        )
    }

    public init(
        _ descriptor: Descriptor,
        _ config: Config,
        _ resolved: ResolvedInternetAddress,
        _ securityLayer: SecurityLayer
    ) throws {
        self.descriptor = descriptor
        self.config = config
        self.address = resolved
        hostname = resolved.ipString()
        port = resolved.port
        self.securityLayer = securityLayer
        self.isClosed = false
    }

    // MARK: Close

    deinit {
        // The socket needs to be closed (to close the underlying file descriptor).
        // If descriptors aren't properly freed, the system will run out sooner or later.
        try? self.close()
    }

    public func close() throws {
        if isClosed {
            return
        }

        if libc.close(descriptor.raw) != 0 {
            if errno == EBADF {
                descriptor = -1
                throw SocketsError(.socketIsClosed)
            } else {
                throw SocketsError(.closeSocketFailed)
            }
        }

        // set descriptor to -1 to prevent further use
        descriptor = -1
        isClosed = true
    }
}
