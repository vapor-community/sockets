//
//  InternetSocket.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

public class InternetSocket: Socket {
    
    public let rawSocket: RawSocket
    public let address: InternetAddress
    // public let address : addrinfo
    
    public var descriptor: Descriptor {
        return self.rawSocket.descriptor
    }
    
    public init(rawSocket: RawSocket, address: InternetAddress) {
        self.rawSocket = rawSocket
        self.address = address
    }
    
    public func close() throws {
        try self.rawSocket.close()
    }
}


