//
//  UDPClient.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

import SocksCore

public class UDPClient: InternetClient {
    
    public init(internetAddress: InternetAddress) throws {
        try super.init(socketConfig: .UDP(), internetAddress: internetAddress)
    }
}
