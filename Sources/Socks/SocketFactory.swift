//
//  SocketFactory.swift
//  Socks
//
//  Created by Matthias Kreileder on 28/03/2016.
//
//

import Foundation
import SocksCore

#if os(Linux)
    import Glibc
    typealias socket_addrinfo = Glibc.addrinfo
    private let socket_connect = Glibc.connect
#else
    import Darwin
    typealias socket_addrinfo = Darwin.addrinfo
    private let socket_connect = Darwin.connect
#endif

public class SocketFactory {
    

 
    
    public init(){
        
    }
    
    public func createAndConnectTcpClientSocket(hostName : String, port : Port) throws -> InternetSocket? {
        
        let socket_Config = SocketConfig(addressFamily: .UNSPECIFIED, socketType: .Stream, protocolType: .TCP)
        let portnumber = String(port)
        
        var servinfo = UnsafeMutablePointer<socket_addrinfo>.init(nil)
        servinfo = try! resolveHostnameAndServiceToIPAddresses(socket_Config,
                                                               hostname : hostName,
                                                               service : portnumber)
        
        // This is where the magic happens!
        var sInfoPtr = servinfo

        while(sInfoPtr != nil){
            // Create a raw socket; try next address in case it doesn't work
            let rawSocket = createRawSocketFromCTypeArguments(sInfoPtr.pointee)
            //here check property or RawSocket
            if (rawSocket.descriptor < 0){
                // Socket creation failed; try next address
                sInfoPtr = sInfoPtr.pointee.ai_next
                continue
            }
            
            
            // Establish the connection to the echo server
            if (socket_connect(rawSocket.descriptor,sInfoPtr.pointee.ai_addr,sInfoPtr.pointee.ai_addrlen) == 0){
                // Socket connection succeeded
                let addr = InternetAddress(address: .Hostname(hostName), port: port)
                
                let socket = InternetSocket(rawSocket: rawSocket, address: addr)

                // Prevent memory leaks: getaddrinfo creates an unmanaged linked list on the heap
                freeaddrinfo(servinfo)
                
                return socket

            }
            
            // When we reach this line then socket connect failed; try next address
            try! rawSocket.close()
            
            sInfoPtr = sInfoPtr.pointee.ai_next
        }
        
        
        return nil
    }
 
    
    private func createRawSocketFromCTypeArguments(rawSocketCTypeInfo : socket_addrinfo) -> RawSocket{
        // protocol protocolType: Protocol
        var protocolFamily: ProtocolFamily
        if (rawSocketCTypeInfo.ai_family == PF_INET){
            protocolFamily = .Inet
        }
        else{
            protocolFamily = .Inet6
        }
        
        var socketType: SocketType
        if (rawSocketCTypeInfo.ai_socktype == SOCK_STREAM){
            socketType = .Stream
        }
        else{
            socketType = .Datagram
        }
        

        if (rawSocketCTypeInfo.ai_protocol == IPPROTO_TCP){
            let raw = try! RawSocket(protocolFamily: protocolFamily, socketType: socketType, protocol: .TCP)
            return raw
        }
        else{
            let raw = try! RawSocket(protocolFamily: protocolFamily, socketType: socketType, protocol: .UDP)
            return raw
        }

    }
    
}