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

public enum ProtocolFamily {
    case Inet
}

public enum SocketType {
    case Stream
    case Datagram
}

public enum Protocol {
    case TCP
    case UDP
}

public enum AddressFamily {
    case Inet
}

public typealias Descriptor = Int32
public typealias Port = UInt16

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
        case .Stream:
        #if os(Linux) 
            return Int32(SOCK_STREAM.rawValue)
        #else
            return SOCK_STREAM
        #endif
        
        case .Datagram:
        #if os(Linux)
            return Int32(SOCK_DGRAM.rawValue)
        #else
            return SOCK_DGRAM
        #endif
        }
    }
}

extension Protocol: CTypeInt32Convertible {
    func toCType() -> Int32 {
        switch self {
        case .TCP: return Int32(IPPROTO_TCP) //needs manual casting bc Linux
        case .UDP: return Int32(IPPROTO_UDP)
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




