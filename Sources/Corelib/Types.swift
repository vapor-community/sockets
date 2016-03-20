//
//  Types.swift
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

enum ProtocolFamily {
    case Inet
}

enum SocketType {
    case Stream
}

enum Protocol {
    case TCP
}

enum AddressFamily {
    case Inet
}

typealias Descriptor = Int32
typealias Port = UInt16

//Extensions

protocol CTypeInt32Convertible {
    func toCType() -> Int32
}

extension ProtocolFamily: CTypeInt32Convertible {
    func toCType() -> Int32 {
        switch self {
        case .Inet: return PF_INET
        }
    }
}

extension SocketType: CTypeInt32Convertible {
    func toCType() -> Int32 {
        switch self {
        case .Stream: return SOCK_STREAM
        }
    }
}

extension Protocol: CTypeInt32Convertible {
    func toCType() -> Int32 {
        switch self {
        case .TCP: return IPPROTO_TCP
        }
    }
}

extension AddressFamily: CTypeInt32Convertible {
    func toCType() -> Int32 {
        switch self {
        case .Inet: return AF_INET
        }
    }
}




