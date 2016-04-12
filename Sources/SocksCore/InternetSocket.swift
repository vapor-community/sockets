//
//  InternetSocket.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

public class InternetSocket: Socket {
    
    public let rawSocket: RawSocket
    public let address: InternetAddress //change to ResolvedInternetAddress
    // NOT public let address : addrinfo
    
    public var descriptor: Descriptor {
        return self.rawSocket.descriptor
    }
    
    public init(rawSocket: RawSocket, address: /*Resolved*/InternetAddress) {
        self.rawSocket = rawSocket
        self.address = address
    }
    
    /*
    public init(rawSocket: RawSocket, address: InternetAddress) {
        //1. calls the resolver, takes the first matching resolved address
        //2. calls the init above
    }
    */
 
    public func close() throws {
        try self.rawSocket.close()
    }
}


