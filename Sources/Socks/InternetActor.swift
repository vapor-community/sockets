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
    let address: InternetAddress
    
    public init(socketConfig: SocketConfig, internetAddress: InternetAddress) throws {
        self.config = socketConfig
        self.address = internetAddress
    }
    
    public func getSocket() throws -> Socket {
        if let socket = self.socket {
            return socket
        }
        
        let socket = try InternetSocket(socketConfig: self.config, address: self.address)
        self.socket = socket
        return socket
    }
}

