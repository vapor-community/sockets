//
//  TCPClient.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

import SocksCore

public class InternetClient: InternetActor, Client {
    
    override init(socketConfig: SocketConfig, internetAddress: InternetAddress) throws {
        try super.init(socketConfig : socketConfig, internetAddress :  internetAddress)
        guard let _ = try self.getSocket() as? ClientSocket else {
            fatalError("Usage error: socket should be a ClientSocket")
        }
    }
}

