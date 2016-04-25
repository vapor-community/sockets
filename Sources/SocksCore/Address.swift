//
//  Address.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

// Generic data type for specifying addresses associated with a socket
// Note: That does not necessarily mean internet addresses
struct RawAddress {
    let family: AddressFamily   // e.g. AF_INET, which means IPv4
    let bytes: Bytes14          // Family-specific address information
}

// Eventually we will make calls to the berkley sockets api provided by the kernel.
// Hence, address objects need to be convertable to the sockaddr structure.
protocol Address {
    func toCType() throws -> sockaddr
}

// Internet address

typealias RawInternetAddress = Int32

//
//  Brief: Specify an internet address
//
//  Example of the (assumend) main use case:
//  assign a string to the hostname e.g. www.google.com
//  and specify the Port via an integer or a service name
//
//  hostname -  can be set to a string that denotes 
//              a hostname e.g. "localhost" or
//              an IPv4 address e.g. "127.0.0.1" or
//              an IPv6 address e.g. "::1"
//
//  port    -   see comments for Port enum
//
public struct Internet_Address {
    public let hostname : String
    public let port :Port
    
    public init(hostname : String, port :Port) {
        self.hostname = hostname
        self.port = port
    }
}

public struct ResolvedInternetAddress {
    
    // The unresoved InternetAddress
    private let internetAddress : Internet_Address
    public var InternetAddress : Internet_Address{
        return internetAddress
    }

    public let resolvedCTypeAddress : addrinfo
    
    public init(internetAddress : Internet_Address, resolvedCTypeAddress : addrinfo){
        self.internetAddress = internetAddress
        self.resolvedCTypeAddress = resolvedCTypeAddress
    }
}