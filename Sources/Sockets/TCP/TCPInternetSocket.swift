import libc
import Dispatch

public final class TCPInternetSocket {
    // program
    public let scheme: String
    public let hostname: String
    public let port: Port

    // sockets
    public let addresses: [ResolvedInternetAddress]
    public private(set) var descriptor: Descriptor
    public let config: Config
    public private(set) var isClosed: Bool

    // MARK: Init

    public convenience init(
        scheme: String = "http",
        hostname: String = "0.0.0.0",
        port: Port = 80
    ) throws {
        let address = InternetAddress(
            hostname: hostname,
            port: port
        )
        try self.init(address, scheme: scheme)
    }

    public convenience init(
        _ address: InternetAddress,
        scheme: String = "http"
    ) throws {
        var conf = Config.TCP(addressFamily: address.addressFamily)
        let resolved = try address.resolve(with: &conf)
        let descriptor = try Descriptor(conf)
        try self.init(
            descriptor,
            conf,
            resolved,
            scheme: scheme,
            hostname: address.hostname
        )
    }

    public init(
        _ descriptor: Descriptor,
        _ config: Config,
        _ resolved: [ResolvedInternetAddress],
        scheme: String = "http",
        hostname: String = "0.0.0.0"
    ) throws {
        self.descriptor = descriptor
        self.config = config
        self.addresses = resolved
        self.hostname = hostname
        port = resolved.first!.port //Should be the same
        self.scheme = scheme
        self.isClosed = false
    }

    // MARK: Client

    public func connect() throws {
        if isClosed { throw SocketsError(.socketIsClosed) }
        
        var res: Int32 = -1
        
        for address in addresses {
            res = libc.connect(descriptor.raw, address.raw, address.rawLen)
            
            if res > -1 {
                print(address.raw)
                break   //Connection works
            }
        }
        
        guard res > -1 else {
            switch errno {
            case EINTR:
                // special case: socket connect has become async.
                // we must wait until it is ready
                let group = DispatchGroup()
                group.enter()
                let write = DispatchSource.makeWriteSource(fileDescriptor: descriptor.raw)
                write.setEventHandler {
                    group.leave()
                }
                group.wait()
                return
            default:
                throw SocketsError(.connectFailed(
                    scheme: scheme,
                    hostname: hostname,
                    port: port
                    ))
            }
        }
    }

    // MARK: Server

    public func listen(max: Int) throws {
        if isClosed { throw SocketsError(.socketIsClosed) }
        let res = libc.listen(descriptor.raw, Int32(max % Int(Int32.max)))
        guard res > -1 else { throw SocketsError(.listenFailed) }
    }

    public func accept() throws -> TCPInternetSocket {
        if isClosed { throw SocketsError(.socketIsClosed) }
        var length = socklen_t(MemoryLayout<sockaddr_storage>.size)
        let addr = UnsafeMutablePointer<sockaddr_storage>.allocate(capacity: 1)
        let addrSockAddr = UnsafeMutablePointer<sockaddr>(OpaquePointer(addr))
        let clientSocketDescriptor = libc.accept(descriptor.raw, addrSockAddr, &length)

        guard clientSocketDescriptor > -1 else {
            addr.deallocate(capacity: 1)
            if errno == SocketsError.interruptedSystemCall {
                return try accept()
            }
            throw SocketsError(.acceptFailed)
        }

        let clientAddress = [ResolvedInternetAddress(raw: addr)]
        let clientSocket = try TCPInternetSocket(
            Descriptor(clientSocketDescriptor),
            config,
            clientAddress,
            scheme: scheme,
            hostname: hostname
        )

        return clientSocket
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

// MARK: Socks

extension TCPInternetSocket: TCPReadableSocket { }
extension TCPInternetSocket: TCPWriteableSocket { }
extension TCPInternetSocket: InternetSocket { }

// MARK: Transport

extension TCPInternetSocket: ClientStream { }
extension TCPInternetSocket: ServerStream { }
extension TCPInternetSocket: InternetStream { }


extension TCPInternetSocket: DescriptorRepresentable {
    public func makeDescriptor() -> Descriptor {
        return descriptor
    }
}
