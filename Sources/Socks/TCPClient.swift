//
//  TCPClient.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

import SocksCore

public class TCPClient: InternetClient {
    
    public init(hostname: String, port: Int) throws {
        try super.init(hostname: hostname, port: port) {
            return try RawSocket(protocolFamily: .Inet, socketType: .Stream, protocol: .TCP)
        }
    }
}
