//
//  UDPClient.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

import SocksCore

public class UDPClient: InternetClient {
    
    init(internetAddress: InternetAddress) {
        fatalError("Unimplemented")
//        super.init(hostname: hostname, port: port) {
            //THIS is where we'll create the UDP client, not implemented yet
        //
        // Please note: SocksCore got changed (have a look into TCPClient.swift 
        // for details, because it is a similar situation)
        // Brief: Create a SocketConfig object with 
        // - SocketConfig(addressFamily: .UNSPECIFIED, socketType: .Datagram, protocolType: .UDP)
        // and then call
        // - try super.init(socketConfig : socketConfig, internetAddress : internetAddress)
        //
//            return try RawSocket(protocolFamily: .Inet, socketType: .Datagram, protocol: .UDP)
//        }
    }
}
