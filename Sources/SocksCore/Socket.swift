//
//  Socket.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

#if os(Linux)
    import Glibc
    private let s_socket = Glibc.socket
    private let s_close = Glibc.close
#else
    import Darwin
    private let s_socket = Darwin.socket
    private let s_close = Darwin.close
#endif

public protocol Socket {
    var descriptor: Descriptor { get }
    var config: SocketConfig { get }
    func close() throws
}

extension Socket {
    public func close() throws {
        if s_close(self.descriptor) != 0 {
            throw Error(.CloseSocketFailed)
        }
    }
}

extension Socket {
    static func createNewSocket(config: SocketConfig) throws -> Descriptor {
        let cProtocolFam = config.addressFamily.toCType()
        let cType = config.socketType.toCType()
        let cProtocol = config.protocolType.toCType()
        
        let descriptor = s_socket(cProtocolFam, cType, cProtocol)
        guard descriptor > 0 else { throw Error(.CreateSocketFailed) }
        
        if config.reuseAddress {
            var value: Int32 = 1
            guard setsockopt(descriptor, SOL_SOCKET, SO_REUSEADDR, &value, socklen_t(sizeof(Int32))) != -1 else {
                throw Error(.ReuseAddressSetFailed)
            }
        }
        
        return descriptor
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
    public var reuseAddress: Bool = true
    
    public init(addressFamily: AddressFamily, socketType: SocketType, protocolType: Protocol){
        self.addressFamily = addressFamily
        self.socketType = socketType
        self.protocolType = protocolType
    }
    
    mutating func adjust(for resolvedAddress: ResolvedInternetAddress) throws {
        self.addressFamily = try resolvedAddress.addressFamily()
    }
    
    public static func TCP(addressFamily: AddressFamily = .unspecified) -> SocketConfig {
        return self.init(addressFamily: addressFamily, socketType: .stream, protocolType: .TCP)
    }
    
    public static func UDP(addressFamily: AddressFamily = .unspecified) -> SocketConfig {
        return self.init(addressFamily: addressFamily, socketType: .datagram, protocolType: .UDP)
    }
}


