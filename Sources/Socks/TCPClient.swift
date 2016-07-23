//
//  TCPClient.swift
//  Socks
//
//  Created by Honza Dvorsky on 1/6/16.
//
//

import SocksCore

/// Represents an established TCP connection.
public class TCPClient {
    
    /// The underlying TCP socket.
    public let socket: TCPInternetSocket
    
    /// Returns a string representation of the peer address.
    public func ipAddress() -> String {
        return self.socket.address.ipString()
    }
    
    /// Creates a client with an already connectied socket.
    public init(alreadyConnectedSocket: TCPInternetSocket) throws {
        self.socket = alreadyConnectedSocket
    }

    /// Creates a client wrapping `socket`, connecting with the timeout of `timeout` seconds.
    public convenience init(socket: TCPInternetSocket, connectionTimeout timeout: Double? = nil) throws {
        try self.init(alreadyConnectedSocket: socket)
        try self.socket.connect(withTimeout: timeout)
    }
    
    /// Creates a client connecting to `address`, connecting with the timeout of `timeout` seconds.
    public convenience init(address: InternetAddress, connectionTimeout timeout: Double? = nil) throws {
        let socket = try TCPInternetSocket(address: address)
        try self.init(socket: socket, connectionTimeout: timeout)
    }
    
    /// Sends `bytes` on socket.
    public func send(bytes: [UInt8]) throws {
        try self.socket.send(data: bytes)
    }
    
    /// Returns received maximum of `maxBytes` bytes, blocks until bytes are available.
    public func receive(maxBytes: Int) throws -> [UInt8] {
        return try self.socket.recv(maxBytes: maxBytes)
    }
    
    /// Returns all readable bytes from socket, blocks until bytes are available.
    public func receiveAll() throws -> [UInt8] {
        return try self.socket.recvAll()
    }
    
    /// Closes and disconnects the client.
    public func close() throws {
        try self.socket.close()
    }
}

extension TCPClient: CustomStringConvertible {
    public var description: String {
        return "TCP on \(socket.address.description)"
    }
}
