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
    
    public init(address: InternetAddress) throws {
        self.address = address
    }
    
    public convenience init(port: UInt16, bindLocalhost: Bool = false) throws {
        let address: InternetAddress = bindLocalhost ? .localhost(port: port) : .any(port: port)
        try self.init(address: address)
    }
    
    @noreturn public func startWithHandler(handler: (client: TCPClient) throws -> ()) throws {
        
        let server = try TCPInternetSocket(address: address)
        try server.bind()
        try server.listen(queueLimit: 4096)
        
        while true {
            let socket = try server.accept()
            let client = try TCPClient(alreadyConnectedSocket: socket)
            try handler(client: client)
        }
    }
}
