//
//  TCPClient.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

import SocksCore

public class InternetClient: InternetActor, Client {
    
    override init(hostname: String, port: Int, rawSocketProvider: () throws -> RawSocket) throws {
        try super.init(hostname: hostname, port: port, rawSocketProvider: rawSocketProvider)
        guard let clientSocket = try self.getSocket() as? ClientSocket else {
            fatalError("Usage error: socket should be a ClientSocket")
        }
        try! clientSocket.connect()
    }
}

