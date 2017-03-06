import Dispatch

#if os(Linux)
    import Glibc
    private let socket_bind = Glibc.bind
    private let socket_connect = Glibc.connect
    private let socket_listen = Glibc.listen
    private let socket_accept = Glibc.accept
    private let socket_recv = Glibc.recv
    private let socket_send = Glibc.send
    private let socket_close = Glibc.close
    private let SOCKET_NOSIGNAL = Glibc.MSG_NOSIGNAL
#else
    import Darwin
    private let socket_connect = Darwin.connect
    private let socket_bind = Darwin.bind
    private let socket_listen = Darwin.listen
    private let socket_accept = Darwin.accept
    private let socket_recv = Darwin.recv
    private let socket_send = Darwin.send
    private let socket_close = Darwin.close
    private let SOCKET_NOSIGNAL = Darwin.SO_NOSIGPIPE
#endif

public protocol TCPSocket: RawSocket { }

public protocol TCPWriteableSocket: TCPSocket { }

public protocol TCPReadableSocket: TCPSocket { }

extension TCPReadableSocket {
    public func recv(maxBytes: Int = BufferCapacity) throws -> [UInt8] {
        let data = Bytes(capacity: maxBytes)
        let flags: Int32 = 0 //FIXME: allow setting flags with a Swift enum
        let receivedBytes = socket_recv(self.descriptor, data.rawBytes, data.capacity, flags)
        guard receivedBytes != -1 else {
            if errno == ECONNRESET {
                // closed by peer, need to close this side.
                // Since this is not an error, no need to throw unless the close
                // itself throws an error.
                _ = try self.close()
                return []
            } else {
                throw SocksError(.readFailed)
            }
        }
      
        guard receivedBytes > 0 else {
            // receiving 0 indicates a proper close .. no error.
            // attempt a close, no failure possible because throw indicates already closed
            // if already closed, no issue.
            // do NOT propogate as error
            _ = try? self.close()
            return []
        }
        let finalBytes = data.characters[0..<receivedBytes]
        return Array(finalBytes)
    }

    public func recvAll() throws -> [UInt8] {
        var buffer: [UInt8] = []
        let chunkSize = 512
        while true {
            let newData = try self.recv(maxBytes: chunkSize)
            buffer.append(contentsOf: newData)
            if newData.count < chunkSize {
                break
            }
        }
        return buffer
    }
}


extension TCPWriteableSocket {

    public func send(data: [UInt8]) throws {
        let len = data.count
        let flags = Int32(SOCKET_NOSIGNAL) //FIXME: allow setting flags with a Swift enum
        let sentLen = socket_send(self.descriptor, data, len, flags)
        guard sentLen == len else { throw SocksError(.sendFailedToSendAllBytes) }
    }
}

public class TCPInternetSocket: InternetSocket, TCPSocket, TCPReadableSocket, TCPWriteableSocket {

    public private(set) var descriptor: Descriptor
    public let config: SocketConfig
    public let address: ResolvedInternetAddress
    public private(set) var isClosed: Bool

    public required init(descriptor: Descriptor?, config: SocketConfig, address: ResolvedInternetAddress) throws {
        if let descriptor = descriptor {
            self.descriptor = descriptor
        } else {
            self.descriptor = try TCPInternetSocket.createNewSocket(config: config)
        }
        self.config = config
        self.address = address
        self.isClosed = false

        try setReuseAddress(true)
    }
    
    deinit {
        // The socket needs to be closed (to close the underlying file descriptor).
        // If descriptors aren't properly freed, the system will run out sooner or later.
        try? self.close()
    }

    public convenience init(address: InternetAddress) throws {
        var conf: SocketConfig = .TCP(addressFamily: address.addressFamily)
        let resolved = try address.resolve(with: &conf)
        try self.init(descriptor: nil, config: conf, address: resolved)
    }

    public func connect() throws {
        if isClosed { throw SocksError(.socketIsClosed) }
        let res = socket_connect(self.descriptor, address.raw, address.rawLen)
        guard res > -1 else { throw SocksError(.connectFailed) }
    }

    public func connect(withTimeout timeout: Double?) throws {
        if isClosed { throw SocksError(.socketIsClosed) }

        guard let to = timeout else {
            try connect()
            return
        }

        //set to nonblocking
        self.blocking = false

        //set back to blocking at the end
        defer { self.blocking = true }


        //call connect
        do {
            try connect()
        } catch {
            //only allow error "in progress"
            guard let err = error as? SocksError, err.number == EINPROGRESS else {
                throw error
            }
        }

        //wait for writeable socket or timeout
        let (_, writes, _) = try select(writes: [descriptor], timeout: timeval(seconds: to))
        guard !writes.isEmpty else {
            throw SocksError(.connectTimedOut)
        }

        //ensure no error was encountered
        let err = try self.getErrorCode()
        guard err == 0 else {
            throw SocksError(.connectFailedWithSocketErrorCode(err))
        }
    }

    public func listen(queueLimit: Int32 = 4096) throws {
        if isClosed { throw SocksError(.socketIsClosed) }
        let res = socket_listen(self.descriptor, queueLimit)
        guard res > -1 else { throw SocksError(.listenFailed) }
    }

    public func accept() throws -> TCPInternetSocket {
        if isClosed { throw SocksError(.socketIsClosed) }
        var length = socklen_t(MemoryLayout<sockaddr_storage>.size)
        let addr = UnsafeMutablePointer<sockaddr_storage>.allocate(capacity: 1)
        let addrSockAddr = UnsafeMutablePointer<sockaddr>(OpaquePointer(addr))
        let clientSocketDescriptor = socket_accept(self.descriptor, addrSockAddr, &length)
        guard clientSocketDescriptor > -1 else {
            addr.deallocate(capacity: 1)
            if errno == SocksError.interruptedSystemCall {
                return try accept()
            }
            throw SocksError(.acceptFailed)
        }
        let clientAddress = ResolvedInternetAddress(raw: addr)
        let clientSocket = try TCPInternetSocket(descriptor: clientSocketDescriptor,
                                                 config: config,
                                                 address: clientAddress)
        return clientSocket
    }

    public func close() throws {
        if isClosed {
            return
        }

        if socket_close(descriptor) != 0 {
            if errno == EBADF {
                descriptor = -1
                throw SocksError(.socketIsClosed)
            } else {
                throw SocksError(.closeSocketFailed)
            }
        }

        // set descriptor to -1 to prevent further use
        descriptor = -1
        isClosed = true
    }

    public func send(data: [UInt8]) throws {
        let len = data.count
        let flags = Int32(SOCKET_NOSIGNAL) //FIXME: allow setting flags with a Swift enum
        let sentLen = socket_send(self.descriptor, data, len, flags)
        guard sentLen == len else {
            throw SocksError(.sendFailedToSendAllBytes)
        }
    }
}

public class TCPEstablishedSocket: TCPSocket {

    public let isClosed = false
    public let descriptor: Descriptor

    public init(descriptor: Descriptor) {
        self.descriptor = descriptor
    }
}

public class TCPEstablishedWriteableSocket: TCPEstablishedSocket, TCPWriteableSocket { }
public class TCPEstablishedReadableSocket: TCPEstablishedSocket, TCPReadableSocket { }
