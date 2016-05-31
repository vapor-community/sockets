//
//  Socket.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

#if os(Linux)
    import Glibc
    private let socket_close = Glibc.close
#else
    import Darwin
    private let socket_close = Darwin.close
#endif

public protocol Socket {
    var descriptor: Descriptor { get }
    func send(data: [UInt8]) throws
    func recv(maxBytes: Int) throws -> [UInt8]
    func close() throws
}

public protocol ClientSocket: Socket {
    func connect() throws
}

public protocol ServerSocket: Socket {
    func bind() throws
    func listen(queueLimit: Int32) throws
    func accept() throws -> Socket
}

public class RawSocket : Socket {
    
    public let descriptor: Descriptor
    public let socketConfig : SocketConfig
    
    private init(descriptor: Descriptor, socketConfig: SocketConfig) throws {
        
        self.socketConfig = socketConfig
        self.descriptor = descriptor
    }
    
    public convenience init(socketConfig: SocketConfig) throws {
        let cProtocolFam = socketConfig.addressFamily.toCType()
        let cType = socketConfig.socketType.toCType()
        let cProtocol = socketConfig.protocolType.toCType()
        
        let descriptor = socket(cProtocolFam, cType, cProtocol)
        guard descriptor > 0 else { throw Error(.CreateSocketFailed) }
        
        try self.init(descriptor: descriptor, socketConfig: socketConfig)
    }
    
    public func close() throws {
        if socket_close(self.descriptor) != 0 {
            throw Error(.CloseSocketFailed)
        }
    }
    
    func copyWithNewDescriptor(descriptor: Descriptor) throws -> RawSocket {
        return try RawSocket(descriptor: descriptor, socketConfig: self.socketConfig)
    }
}

/*
 *  A SocketConfig bundels together the information needed to
 *  create a socket 
 */
public struct SocketConfig {

    public var addressFamily: AddressFamily
    public let socketType: SocketType
    public let protocolType: Protocol
    
    public init(addressFamily: AddressFamily, socketType: SocketType, protocolType: Protocol){
        self.addressFamily = addressFamily
        self.socketType = socketType
        self.protocolType = protocolType
    }
    
    public static func TCP() -> SocketConfig {
        return self.init(addressFamily: .unspecified, socketType: .stream, protocolType: .TCP)
    }
    
    public static func UDP() -> SocketConfig {
        return self.init(addressFamily: .unspecified, socketType: .datagram, protocolType: .UDP)
    }
}


