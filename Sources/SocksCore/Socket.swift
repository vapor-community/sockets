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
    let protocolFamily: ProtocolFamily
    let socketType: SocketType
    let protocolType: Protocol
    
    private init(descriptor: Descriptor, protocolFamily: ProtocolFamily = .Inet, socketType: SocketType, protocolType: Protocol) throws {
        
        self.protocolFamily = protocolFamily
        self.socketType = socketType
        self.protocolType = protocolType
        self.descriptor = descriptor
    }
    
    public convenience init(protocolFamily: ProtocolFamily = .Inet, socketType: SocketType, protocol protocolType: Protocol) throws {
        
        let cProtocolFam = protocolFamily.toCType()
        let cType = socketType.toCType()
        let cProtocol = protocolType.toCType()
        
        let descriptor = socket(cProtocolFam, cType, cProtocol)
        guard descriptor > 0 else { throw Error(.CreateSocketFailed) }
        
        try self.init(descriptor: descriptor, protocolFamily: protocolFamily, socketType: socketType, protocolType: protocolType)
    }
    
    public func close() throws {
        if socket_close(self.descriptor) != 0 {
            throw Error(.CloseSocketFailed)
        }
    }
    
    func copyWithNewDescriptor(descriptor: Descriptor) throws -> RawSocket {
        return try RawSocket(descriptor: descriptor, protocolFamily: self.protocolFamily, socketType: self.socketType, protocolType: self.protocolType)
    }
}

extension RawSocket {
    
    public static func TCP() throws -> RawSocket {
        return try RawSocket(protocolFamily: .Inet, socketType: .Stream, protocol: .TCP)
    }
    
    public static func UDP() throws -> RawSocket {
        return try RawSocket(protocolFamily: .Inet, socketType: .Datagram, protocol: .UDP)
    }
}





