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
    case Inet6
}

public enum SocketType {
    case Stream
    case Datagram
}

public enum Protocol {
    case TCP
    case UDP
}

// Defining the space to which the address belongs
public enum AddressFamily {
    case Inet           // IPv4
    case Inet6          // IPv6
    case UNSPECIFIED    // If you do not care if IPv4 or IPv6 - the name
                        // resolution will dynamically decide if IPv4 or 
                        // IPv6 is applicable
}

public typealias Descriptor = Int32
public typealias Port = UInt16

//
//  A Port can be specified as an integer or
//  as a service: e.g. you can assign a 
//  Port to "echo" or to the number 7
//
public enum KclPort {
    case Servicenameostname(String)
    case Portnumber(UInt16)
}

//Extensions

protocol CTypeStringConvertable {
    func toString() -> String
}

protocol CTypeInt32Convertible {
    func toCType() -> Int32
}

protocol CTypeUnsafePointerOfInt8TypeConvertible {
    func toCTypeUnsafePointerOfInt8() -> UnsafePointer<Int8>
}

extension KclPort : CTypeStringConvertable {
    func toString() -> String {
        switch self {
        case .Servicenameostname(let service):
            return service
        case .Portnumber(let portNumber):
            return String(portNumber)
        }
    }
}

extension ProtocolFamily: CTypeInt32Convertible {
    func toCType() -> Int32 {
        switch self {
        case .Inet: return PF_INET
        case .Inet6: return PF_INET6
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
        case .Inet6: return AF_INET6
        case .UNSPECIFIED : return AF_UNSPEC
        }
    }
}


