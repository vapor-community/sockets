//
//  InternetActor.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

import SocksCore

public class InternetActor: Actor {
    
    //let hostname: String
    //let port: Port
    //let rawSocketProvider: () throws -> RawSocket
    
    private var socket: InternetSocket? = nil
    
    /*
    public init(hostname: String, port: UInt16, rawSocketProvider: () throws -> RawSocket) throws {
        self.hostname = hostname
        self.port = port
        self.rawSocketProvider = rawSocketProvider
    }*/
    
    let config: SocketConfig
    let address: Internet_Address
    
    public init(socketConfig : SocketConfig, internetAddress : Internet_Address) throws {
        self.config = socketConfig
        self.address = internetAddress
    }
    
    /*
    public func getSocket() throws -> Socket {
        guard self.socket == nil else { return self.socket! }
        
        let raw = try self.rawSocketProvider()
        let address = Internet_Address(hostname: hostname, port: .Portnumber(self.port))
        self.socket = InternetSocket(rawSocket: raw, address: address)

        return self.socket!
    }*/
    public func getSocket() throws -> Socket {
        guard self.socket == nil else { return self.socket! }
        
        self.socket = try InternetSocket(socketConfig: self.config, address: self.address)
        return self.socket!
    }
}

