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

public enum InternetAddressType {
    case Hostname(String)
    case IPv4(Bytes4)
    case IPv6(Bytes16)
}

public struct InternetAddress: Address {
    
    public let address: InternetAddressType
    public let port: Port
    
    public init(address: InternetAddressType, port: Port) {
        self.address = address
        self.port = port
    }
}

