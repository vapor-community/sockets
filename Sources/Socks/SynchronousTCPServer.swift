//
//  SynchronousTCPServer.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

import SocksCore

public class SynchronousTCPServer {
    
    public let address: InternetAddress
    
    public init(port: UInt16) throws {
        self.address = .localhost(port: 8080)
    }
    
    @noreturn public func startWithHandler(handler: (client: TCPClient) throws -> ()) throws {
        
        let server = try TCPSocket(address: address)
        try server.bind()
        try server.listen(queueLimit: 4096)
        
        while true {
            let socket = try server.accept()
            let client = try TCPClient(alreadyConnectedSocket: socket)
            try handler(client: client)
        }
    }
}
