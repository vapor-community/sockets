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

struct RawAddress {
    let family: AddressFamily
    let bytes: Bytes14
}

protocol Address {
    func toCType() throws -> sockaddr
}

// Internet address

typealias RawInternetAddress = Int32

public enum InternetAddressType {
    case Hostname(String)
    case IPv4(Bytes4)
}

public struct InternetAddress: Address {
    
    public let address: InternetAddressType
    public let port: Port
    
    public init(address: InternetAddressType, port: Port) {
        self.address = address
        self.port = port
    }
}

