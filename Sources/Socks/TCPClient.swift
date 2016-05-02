//
//  TCPClient.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

import SocksCore

public class TCPClient: InternetClient {
    
    //TODO: needs more thought
    func tcpSocket() throws -> ClientSocket {
        return try self.getSocket() as! ClientSocket
    }
    
    public init(internetAddress: InternetAddress) throws {
        
        try super.init(socketConfig: .TCP(), internetAddress: internetAddress)
        try tcpSocket().connect()
    }
}
