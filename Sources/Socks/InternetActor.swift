//
//  InternetActor.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

import SocksCore

public class InternetActor: Actor {
    
    let hostname: String
    let port: Int
    let rawSocketProvider: () throws -> RawSocket
    
    private var socket: InternetSocket? = nil
    
    public init(hostname: String, port: Int, rawSocketProvider: () throws -> RawSocket) throws {
        self.hostname = hostname
        self.port = port
        self.rawSocketProvider = rawSocketProvider
    }
    
    public func getSocket() throws -> Socket {
        guard self.socket == nil else { return self.socket! }
        
        let raw = try self.rawSocketProvider()
        let address = InternetAddress(address: .Hostname(self.hostname), port: UInt16(self.port))
        self.socket = InternetSocket(rawSocket: raw, address: address)

        return self.socket!
    }
}

