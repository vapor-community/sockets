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

enum InternetAddressType {
    case Hostname(String)
    case IPv4(Bytes4)
}

struct InternetAddress: Address {
    let port: Port
    let address: InternetAddressType
}

