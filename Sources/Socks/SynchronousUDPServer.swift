//
//  SynchronousUDPServer.swift
//  Socks
//
//  Created by Honza Dvorsky on 6/1/16.
//
//

import SocksCore

public class SynchronousUDPServer {
    
    public let address: InternetAddress
    
    public init(port: UInt16) throws {
        self.address = .localhost(port: 8080)
    }
    
    @noreturn public func startWithHandler(handler: (received: [UInt8], client: UDPClient) throws -> ()) throws {
        
        let server = try UDPSocket(address: address)
        try server.bind()
        
        while true {
            let (data, sender) = try server.recvfrom()
            let client = try UDPClient(address: sender)
            try handler(received: data, client: client)
        }
    }
}
