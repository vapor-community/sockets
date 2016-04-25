//
//  TCPClient.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

import SocksCore

public class TCPClient: InternetClient {
    
    public init(internetAddress : Internet_Address) throws {
        
        let socketConfig = SocketConfig(addressFamily: .UNSPECIFIED, socketType: .Stream, protocolType: .TCP)
        
        try super.init(socketConfig : socketConfig, internetAddress : internetAddress)
    }
}
