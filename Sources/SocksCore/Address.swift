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
//  and specify the Port via an integer
//
//  hostname -  can be set to a string that denotes 
//              a hostname e.g. "localhost" or
//              an IPv4 address e.g. "127.0.0.1" or
//              an IPv6 address e.g. "::1"
//
//  port    -   see comments for Port enum
//
//  addressFamily - for specifying a preference for IP version
//
public struct InternetAddress {
    public let hostname: String
    public let port: Port
    public let addressFamily: AddressFamily
    
    public init(hostname: String, port: Port, addressFamily: AddressFamily = .unspecified) {
        self.hostname = hostname
        self.port = port
        self.addressFamily = addressFamily
    }
    
    static public func localhost(port: UInt16, ipVersion: AddressFamily = .inet) -> InternetAddress {
        let hostname: String
        let ipV: AddressFamily
        switch ipVersion {
        case .inet6:
            hostname = "::1"
            ipV = .inet6
        default:
            hostname = "127.0.0.1"
            ipV = .inet
        }
        return InternetAddress(hostname: hostname, port: port, addressFamily: ipV)
    }
    
    static public func any(port: UInt16, ipVersion: AddressFamily = .inet) -> InternetAddress {
        let hostname: String
        let ipV: AddressFamily
        switch ipVersion {
        case .inet6:
            hostname = "::"
            ipV = .inet6
        default:
            hostname = "0.0.0.0"
            ipV = .inet
        }
        return InternetAddress(hostname: hostname, port: port, addressFamily: ipV)
    }
}

extension InternetAddress {
    
    func resolve(with config: inout SocketConfig) throws -> ResolvedInternetAddress {
        return try Resolver().resolve(self, with: &config)
    }
}

public class ResolvedInternetAddress {
    
    let _raw: UnsafeMutablePointer<sockaddr_storage>
    var raw: UnsafeMutablePointer<sockaddr> {
        return UnsafeMutablePointer<sockaddr>(OpaquePointer(_raw))
    }
    
    /// WARNING: this pointer MUST be +1 allocated, ResolvedInternetAddress
    /// will make sure of deallocating it later.
    init(raw: UnsafeMutablePointer<sockaddr_storage>) {
        self._raw = raw
        precondition((try! addressFamily()).isConcrete(), "Cannot create ResolvedInternetAddress with a unspecified address family")
    }

    var rawLen: socklen_t {
        switch try! addressFamily() {
        case .inet: return socklen_t(MemoryLayout<sockaddr_in>.size)
        case .inet6: return socklen_t(MemoryLayout<sockaddr_in6>.size)
        default: return 0
        }
    }
    
    public var port: UInt16 {
        let val: UInt16
        switch try! addressFamily() {
        case .inet: val = UnsafePointer<sockaddr_in>(OpaquePointer(_raw)).pointee.sin_port
        case .inet6: val = UnsafePointer<sockaddr_in6>(OpaquePointer(_raw)).pointee.sin6_port
        default: fatalError()
        }
        return htons(val)
    }
    
    public func addressFamily() throws -> AddressFamily {
        return try AddressFamily(fromCType: Int32(_raw.pointee.ss_family))
    }
    
    public func ipString() -> String {
        
        guard let family = try? addressFamily() else { return "Invalid family" }
        let cfamily = family.toCType()
        let strData: UnsafeMutablePointer<Int8>
        let maxLen: socklen_t
        
        switch family {
        case .inet:
            maxLen = socklen_t(INET_ADDRSTRLEN)
            strData = UnsafeMutablePointer<Int8>.allocate(capacity: Int(maxLen))
            var ptr = UnsafeMutablePointer<sockaddr_in>(OpaquePointer(raw)).pointee.sin_addr
            inet_ntop(cfamily, &ptr, strData, maxLen)
        case .inet6:
            maxLen = socklen_t(INET6_ADDRSTRLEN)
            strData = UnsafeMutablePointer<Int8>.allocate(capacity: Int(maxLen))
            var ptr = UnsafeMutablePointer<sockaddr_in6>(OpaquePointer(raw)).pointee.sin6_addr
            inet_ntop(cfamily, &ptr, strData, maxLen)
        case .unspecified:
            fatalError("ResolvedInternetAddress should never be unspecified")
        }
        
        let maybeStr = String(validatingUTF8: strData)
        strData.deallocate(capacity: Int(maxLen))
        
        guard let str = maybeStr else {
            return "Invalid ip string"
        }
        return str
    }
    
    public func asData() -> [UInt8] {
        let data = UnsafeMutablePointer<UInt8>(OpaquePointer(_raw))
        let maxLen = Int(self.rawLen)
        let buffer = UnsafeBufferPointer(start: data, count: maxLen)
        let out = Array(buffer)
        return out
    }

    deinit {
        self._raw.deinitialize(count: 1)
        self._raw.deallocate(capacity: 1)
    }
}

extension ResolvedInternetAddress: Equatable { }
public func ==(lhs: ResolvedInternetAddress, rhs: ResolvedInternetAddress) -> Bool {
    return lhs.asData() == rhs.asData()
}

extension ResolvedInternetAddress: CustomStringConvertible {
    
    public var description: String {
        let family: String
        if let fam = try? self.addressFamily() {
            family = String(describing: fam)
        } else {
            family = "UNRECOGNIZED FAMILY"
        }
        return "\(ipString()):\(port) \(family)"
    }
}

extension Socket {
    
    public func remoteAddress() throws -> ResolvedInternetAddress {
        var length = socklen_t(MemoryLayout<sockaddr_storage>.size)
        let addr = UnsafeMutablePointer<sockaddr_storage>.allocate(capacity: 1)
        let addrSockAddr = UnsafeMutablePointer<sockaddr>(OpaquePointer(addr))
        let res = getpeername(descriptor, addrSockAddr, &length)
        guard res > -1 else {
            addr.deallocate(capacity: 1)
            throw SocksError(.remoteAddressResolutionFailed)
        }
        let clientAddress = ResolvedInternetAddress(raw: addr)
        return clientAddress
    }
    
    public func localAddress() throws -> ResolvedInternetAddress {
        var length = socklen_t(MemoryLayout<sockaddr_storage>.size)
        let addr = UnsafeMutablePointer<sockaddr_storage>.allocate(capacity: 1)
        let addrSockAddr = UnsafeMutablePointer<sockaddr>(OpaquePointer(addr))
        let res = getsockname(descriptor, addrSockAddr, &length)
        guard res > -1 else {
            addr.deallocate(capacity: 1)
            throw SocksError(.localAddressResolutionFailed)
        }
        let clientAddress = ResolvedInternetAddress(raw: addr)
        return clientAddress
    }
}

