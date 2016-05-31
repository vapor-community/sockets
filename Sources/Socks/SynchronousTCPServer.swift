//
//  SynchronousTCPServer.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

import SocksCore

public class SynchronousTCPServer: SynchronousServer {
    
    public init(internetAddress : InternetAddress) throws {
        let server = try InternetServer(socketConfig: .TCP(), internetAddress: internetAddress)
        super.init(server: server)
    }
}
