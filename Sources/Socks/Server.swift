//
//  Server.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

extension Server {

    public func setup() throws {
        
        let socket = try self.getServerSocket()
        
        //bind
        try socket.bind()
        
        //listen
        try socket.listen(queueLimit: 4096)
    }
    
    public func accept() throws -> Actor {
        let socket = try self.getServerSocket().accept()
        let connection = ClientConnection(socket: socket)
        return connection
    }
}
