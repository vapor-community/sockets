//
//  InternetServer.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

import SocksCore

public class InternetServer: InternetActor, Server {
    
    public func getServerSocket() throws -> ServerSocket {
        let socket = try self.getSocket()
        guard let serverSocket = socket as? ServerSocket else {
            fatalError("Usage error: socket should be a ServerSocket")
        }
        return serverSocket
    }
}
