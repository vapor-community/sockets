//
//  TCPClient.swift
//  Socks
//
//  Created by Honza Dvorsky on 1/6/16.
//
//

import SocksCore

public class TCPClient {
    
    public let socket: TCPInternetSocket
    
    public func ipAddress() -> String {
        return self.socket.address.ipString()
    }
    
    public init(alreadyConnectedSocket: TCPInternetSocket) throws {
        self.socket = alreadyConnectedSocket
    }

    public convenience init(socket: TCPInternetSocket) throws {
        try self.init(alreadyConnectedSocket: socket)
        try self.socket.connect()
    }
    
    public convenience init(address: InternetAddress) throws {
        let socket = try TCPInternetSocket(address: address)
        try self.init(socket: socket)
    }
    
    public func send(bytes: [UInt8]) throws {
        try self.socket.send(data: bytes)
    }
    
    public func receive(maxBytes: Int) throws -> [UInt8] {
        return try self.socket.recv(maxBytes: maxBytes)
    }
    
    public func receiveAll() throws -> [UInt8] {
        return try self.socket.recvAll()
    }
    
    public func close() throws {
        try self.socket.close()
    }
}

extension TCPClient: CustomStringConvertible {
    public var description: String {
        return "TCP on \(socket.address.description)"
    }
}
