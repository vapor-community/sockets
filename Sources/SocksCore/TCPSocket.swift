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
#else
    import Darwin
    private let socket_connect = Darwin.connect
    private let socket_bind = Darwin.bind
    private let socket_listen = Darwin.listen
    private let socket_accept = Darwin.accept
    private let socket_recv = Darwin.recv
    private let socket_send = Darwin.send
#endif

public class TCPSocket: InternetSocket {

    public let descriptor: Descriptor
    public let config: SocketConfig
    public let address: ResolvedInternetAddress

    public required init(descriptor: Descriptor?, config: SocketConfig, address: ResolvedInternetAddress) throws {
        
        if let descriptor = descriptor {
            self.descriptor = descriptor
        } else {
            self.descriptor = try TCPSocket.createNewSocket(config: config)
        }
        self.config = config
        self.address = address
    }
    
    public convenience init(address: InternetAddress) throws {
        var config: SocketConfig = .TCP(addressFamily: address.addressFamily)
        let resolved = try address.resolve(with: config)
        config = try config.adjusted(for: resolved)
        try self.init(descriptor: nil, config: config, address: resolved)
    }
    
    public func recv(maxBytes: Int = BufferCapacity) throws -> [UInt8] {
        let data = Bytes(capacity: maxBytes)
        let flags: Int32 = 0 //FIXME: allow setting flags with a Swift enum
        let receivedBytes = socket_recv(self.descriptor, data.rawBytes, data.capacity, flags)
        guard receivedBytes > -1 else { throw Error(.ReadFailed) }
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
    
    public func send(data: [UInt8]) throws {
        let len = data.count
        let flags: Int32 = 0 //FIXME: allow setting flags with a Swift enum
        let sentLen = socket_send(self.descriptor, data, len, flags)
        guard sentLen == len else { throw Error(.SendFailedToSendAllBytes) }
    }
    
    public func connect() throws {
        let res = socket_connect(self.descriptor, address.raw, address.rawLen)
        guard res > -1 else { throw Error(.ConnectFailed) }
    }

    public func listen(queueLimit: Int32 = 4096) throws {
        let res = socket_listen(self.descriptor, queueLimit)
        guard res > -1 else { throw Error(.ListenFailed) }
    }
    
    public func accept() throws -> TCPSocket {
        
        // the type of this variable is big enough to store a IPv6 (and of course a IPv4) address
        // that's important because we don't know upfront if a IPv6 or a IPv4 client wants to connect
        let rawClientAddress = UnsafeMutablePointer<sockaddr_storage>.init(nil)
        
        var length = socklen_t(sizeof(sockaddr_storage))
        let addr = UnsafeMutablePointer<sockaddr>(rawClientAddress)
        
        let clientSocketDescriptor = socket_accept(self.descriptor, addr, &length)
        
        guard clientSocketDescriptor > -1 else { throw Error(.AcceptFailed) }
        
        let clientAddress = ResolvedInternetAddress(raw: addr!.pointee)
        let clientSocket = try TCPSocket(descriptor: clientSocketDescriptor, config: config, address: clientAddress)
        return clientSocket
    }
}
