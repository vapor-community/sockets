//
//  Address.swift
//  Socks
//
//  Created by Matthias Kreileder on 3/20/16.
//
//

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

//
//  Brief: Specify an internet address
//
//  Example of the (assumed) main use case:
//  assign a string to the hostname e.g. google.com
//  and specify the Port via an integer or a service name
//
//  hostname -  can be set to a string that denotes 
//              a hostname e.g. "localhost" or
//              an IPv4 address e.g. "127.0.0.1" or
//              an IPv6 address e.g. "::1"
//
//  port    -   see comments for Port enum
//
public struct InternetAddress {
    public let hostname: String
    public let port: Port
    
    public init(hostname: String, port: Port) {
        self.hostname = hostname
        self.port = port
    }
}

public class ResolvedInternetAddress {
    
    // The unresolved InternetAddress
    let internetAddress: InternetAddress
    
    let resolvedCTypeAddress: UnsafeMutablePointer<addrinfo>
    
    func addressFamily() throws -> AddressFamily {
        return try AddressFamily(fromCType: resolvedCTypeAddress.pointee.ai_family)
    }
    
    init(internetAddress: InternetAddress, resolvedCTypeAddress: UnsafeMutablePointer<addrinfo>){
        self.internetAddress = internetAddress
        self.resolvedCTypeAddress = resolvedCTypeAddress
    }
    
    deinit {
        freeaddrinfo(resolvedCTypeAddress)
    }
}