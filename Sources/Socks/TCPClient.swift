//
//  TCPClient.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

import SocksCore

public class TCPClient: InternetClient {
    
    public init(internetAddress : InternetAddress) throws {
        
        let socketConfig = SocketConfig(addressFamily: .Unspecified, socketType: .Stream, protocolType: .TCP)
        
        try super.init(socketConfig : socketConfig, internetAddress : internetAddress)
    }
}
