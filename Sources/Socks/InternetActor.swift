//
//  InternetActor.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

import SocksCore

public class InternetActor: Actor {
    
    private var socket: InternetSocket? = nil
    
    let config: SocketConfig
    let address: Internet_Address
    
    public init(socketConfig : SocketConfig, internetAddress : Internet_Address) throws {
        self.config = socketConfig
        self.address = internetAddress
    }
    
    public func getSocket() throws -> Socket {
        guard self.socket == nil else { return self.socket! }
        
        self.socket = try InternetSocket(socketConfig: self.config, address: self.address)
        return self.socket!
    }
}

