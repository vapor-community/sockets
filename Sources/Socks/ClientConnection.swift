//
//  ClientConnection.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

import SocksCore

class ClientConnection: Actor {
    
    let socket: Socket
    
    init(socket: Socket) {
        self.socket = socket
    }
    
    func getSocket() throws -> Socket {
        return self.socket
    }
}
