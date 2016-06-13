//
//  Socket+Impl.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

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
        guard receivedBytes > -1 else { throw Error(.readFailed) }
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
        guard sentLen == len else { throw Error(.sendFailedToSendAllBytes) }
    }
}

public class TCPInternetSocket: InternetSocket, TCPSocket, TCPReadableSocket, TCPWriteableSocket {

    public let descriptor: Descriptor
    public let config: SocketConfig
    public let address: ResolvedInternetAddress
    public var closed: Bool

    public required init(descriptor: Descriptor?, config: SocketConfig, address: ResolvedInternetAddress) throws {
        if let descriptor = descriptor {
            self.descriptor = descriptor
        } else {
            self.descriptor = try TCPInternetSocket.createNewSocket(config: config)
        }
        self.config = config
        self.address = address
        self.closed = false
        
        self.reuseAddress = true
    }
    
    public convenience init(address: InternetAddress) throws {
        var conf: SocketConfig = .TCP(addressFamily: address.addressFamily)
        let resolved = try address.resolve(with: &conf)
        try self.init(descriptor: nil, config: conf, address: resolved)
    }
    
    public func connect() throws {
        let res = socket_connect(self.descriptor, address.raw, address.rawLen)
        guard res > -1 else { throw Error(.connectFailed) }
    }

    public func listen(queueLimit: Int32 = 4096) throws {
        let res = socket_listen(self.descriptor, queueLimit)
        guard res > -1 else { throw Error(.listenFailed) }
    }
    
    public func accept() throws -> TCPInternetSocket {
        var length = socklen_t(sizeof(sockaddr_storage))
        let addr = UnsafeMutablePointer<sockaddr_storage>.init(allocatingCapacity: 1)
        let addrSockAddr = UnsafeMutablePointer<sockaddr>(addr)
        let clientSocketDescriptor = socket_accept(self.descriptor, addrSockAddr, &length)
        guard clientSocketDescriptor > -1 else {
            addr.deallocateCapacity(1)
            throw Error(.acceptFailed)
        }
        let clientAddress = ResolvedInternetAddress(raw: addr)
        let clientSocket = try TCPInternetSocket(descriptor: clientSocketDescriptor,
                                                 config: config,
                                                 address: clientAddress)
        return clientSocket
    }

    public func close() throws {
        closed = true
        if socket_close(self.descriptor) != 0 {
            throw Error(.closeSocketFailed)
        }
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
