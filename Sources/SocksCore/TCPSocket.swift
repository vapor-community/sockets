//
//  Socket+Impl.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

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
        guard receivedBytes > -1 else { throw SocksError(.readFailed) }
        let finalBytes = data.characters[0..<receivedBytes]
        let out = Array(finalBytes.map({ UInt8($0) }))
        return out
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

    public let descriptor: Descriptor
    public let config: SocketConfig
    public let address: ResolvedInternetAddress
    public var closed: Bool
    
    // the DispatchSource if the socket is being watched for reads
    private var watchingSource: DispatchSourceRead?

    public required init(descriptor: Descriptor?, config: SocketConfig, address: ResolvedInternetAddress) throws {
        if let descriptor = descriptor {
            self.descriptor = descriptor
        } else {
            self.descriptor = try TCPInternetSocket.createNewSocket(config: config)
        }
        self.config = config
        self.address = address
        self.closed = false

        try setReuseAddress(true)
    }

    public convenience init(address: InternetAddress) throws {
        var conf: SocketConfig = .TCP(addressFamily: address.addressFamily)
        let resolved = try address.resolve(with: &conf)
        try self.init(descriptor: nil, config: conf, address: resolved)
    }

    public func connect() throws {
        let res = socket_connect(self.descriptor, address.raw, address.rawLen)
        guard res > -1 else { throw SocksError(.connectFailed) }
    }

    public func connect(withTimeout timeout: Double?) throws {

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
        let res = socket_listen(self.descriptor, queueLimit)
        guard res > -1 else { throw SocksError(.listenFailed) }
    }

    public func accept() throws -> TCPInternetSocket {
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
        stopWatching()
        closed = true
        if socket_close(self.descriptor) != 0 {
            throw SocksError(.closeSocketFailed)
        }
    }
    
    /**
        Start watching the socket for available data and execute the `handler`
        on the specified queue if data is ready to be received.
    */
    public func startWatching(on queue:DispatchQueue, handler:@escaping ()->()) throws {
        
        if watchingSource != nil {
            throw SocksError(.generic("Socket is already being watched"))
        }
        
        // dispatch sources only work on non-blocking sockets
        self.blocking = false
        
        // create a read source from the socket's descriptor that will execute the handler on the specified queue if data is ready to be read
        let newSource = DispatchSource.makeReadSource(fileDescriptor: self.descriptor, queue: queue)
        newSource.setEventHandler(handler:handler)
        newSource.resume()
        
        // this source needs to be retained as long as the socket lives (or watching will end)
        watchingSource = newSource
    }
    
    /**
        Stops watching the socket for available data.
    */
    public func stopWatching() {
        watchingSource?.cancel()
        watchingSource = nil
    }
}

public class TCPEstablishedSocket: TCPSocket {

    public let descriptor: Descriptor

    public init(descriptor: Descriptor) {
        self.descriptor = descriptor
    }
}

public class TCPEstablishedWriteableSocket: TCPEstablishedSocket, TCPWriteableSocket { }
public class TCPEstablishedReadableSocket: TCPEstablishedSocket, TCPReadableSocket { }
