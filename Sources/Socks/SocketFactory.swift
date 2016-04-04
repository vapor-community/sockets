//
//  SocketFactory.swift
//  Socks
//
//  Created by Matthias Kreileder on 28/03/2016.
//
//

import Foundation
import SocksCore
/*
#if os(Linux)
    import Glibc
    private let socket_addrinfo = Glibc.addrinfo
#else
    import Darwin
    private let socket_addrinfo = Darwin.addrinfo
#endif
*/
public class SocketFactory {
    
    /*
    
    // Brief: Creates a TCP Socket which listens on the provided port number
    //
    //
    // - Transparently creates a IPv4 or IPv6 socket
    // - binds that socket to the local address and the provided port number
    // - calls listen and sets the queue size for incoming connections to queueLimit
    public func setupTcpServerSocket(port : Port, queueLimit: Int32 = 4096) -> InternetSocket{
        
        // the addrinfo initializer intializes all fields of addressCriteria
        // Hence, there is no need to call memset()
        
        /*
        var addressCriteria = socket_addrinfo.init()
        var pointerToAddressCriteria = UnsafeMutablePointer<addrinfo>(&addressCriteria)
        pointerToAddressCriteria = &addressCriteria
        addressCriteria.ai_family = AF_UNSPEC // IPv4 or IPv6
        addressCriteria.ai_flags = AI_PASSIVE
        addressCriteria.ai_socktype = SOCK_STREAM
        addressCriteria.ai_protocol = IPPROTO_TCP
        
        //List of server addresses
        var serverAddress = UnsafeMutablePointer<addrinfo>.alloc(1)
        
        let nullPointer = UnsafePointer<Int8>()
        let addressSearchSuccessful = getaddrinfo(nil,&port,serverAddress,&serverAddress)
        */
        
        // The 
        
    }
 
    */
}