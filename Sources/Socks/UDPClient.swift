//
//  UDPClient.swift
//  Socks
//
//  Created by Honza Dvorsky on 6/1/16.
//
//

import SocksCore

public class UDPClient {
    
    public let socket: UDPInternetSocket
    
    public func ipAddress() -> String {
        return self.socket.address.ipString()
    }
    
    public init(socket: UDPInternetSocket) throws {
        self.socket = socket
    }
    
    public convenience init(address: InternetAddress) throws {
        let socket = try UDPInternetSocket(address: address)
        try self.init(socket: socket)
    }
    
    public convenience init(address: ResolvedInternetAddress) throws {
        let config: SocketConfig = .UDP(addressFamily: try address.addressFamily())
        let socket = try UDPInternetSocket(descriptor: nil, config: config, address: address)
        try self.init(socket: socket)
    }
    
    public func send(bytes: [UInt8], destination: ResolvedInternetAddress? = nil) throws {
        let address = destination ?? self.socket.address
        try self.socket.sendto(data: bytes, address: address)
    }
    
    public func receive(maxBytes: Int = BufferCapacity) throws -> (data: [UInt8], sender: ResolvedInternetAddress) {
        return try self.socket.recvfrom(maxBytes: maxBytes)
    }

    public func close() throws {
        try socket.close()
    }
}

extension UDPClient: CustomStringConvertible {
    public var description: String {
        return "UDP on \(socket.address.description)"
    }
}

