//
//  SynchronousTCPServer.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

import SocksCore

public class SynchronousTCPServer: SynchronousServer {
    
    public init(hostname: String, port: Int) throws {
        
        let server = try InternetServer(hostname: hostname, port: port) {
            return try RawSocket.TCP()
        }
        super.init(server: server)
    }
}
