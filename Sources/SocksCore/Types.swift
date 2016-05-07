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
    case Unspecified    // If you do not care if IPv4 or IPv6 - the name
                        // resolution will dynamically decide if IPv4 or 
                        // IPv6 is applicable
}

public typealias Descriptor = Int32

//
//  A Port can be specified as an integer or
//  as a service: e.g. you can assign a 
//  Port to "echo" or to the number 7
//
public enum Port {
    case ServiceName(String)
    case PortNumber(UInt16)
}

//Extensions

protocol StringConvertable {
    func toString() -> String
}

protocol CTypeInt32Convertible {
    func toCType() -> Int32
}

protocol CTypeUnsafePointerOfInt8TypeConvertible {
    func toCTypeUnsafePointerOfInt8() -> UnsafePointer<Int8>
}

public protocol Sendable {
    func serialize() -> [UInt8]
}

public protocol Receivable {
    associatedtype TemplateType
    func deserialize(bytes: [UInt8]) throws -> TemplateType
    
    func getSerializedSize() -> Int
}

extension String: Sendable {
    public func serialize() -> [UInt8] {
        return self.toBytes()
    }
}

//extension String: Receivable {
//    typealias TemplateType = String
//    func deserialize(bytes: [UInt8]) throws -> String {
//    return try bytes.toString()
//    }
//}

extension Port: StringConvertable {
    func toString() -> String {
        switch self {
        case .ServiceName(let service):
            return service
        case .PortNumber(let portNumber):
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
        case .Inet: return Int32(AF_INET)
        case .Inet6: return Int32(AF_INET6)
        case .Unspecified : return Int32(AF_UNSPEC)
        }
    }
}

extension AddressFamily {
    
    init(fromCType cType: Int32) throws {
        
        switch cType {
        case Int32(AF_INET): self = .Inet
        case Int32(AF_INET6): self = .Inet6
        case Int32(AF_UNSPEC): self = .Unspecified
        default: throw Error(.UnsupportedSocketAddressFamily(cType))
        }
    }
}


