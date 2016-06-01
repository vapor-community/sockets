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
    
    static public func localhost(port: UInt16) -> InternetAddress {
        return InternetAddress(hostname: "localhost", port: .portNumber(port))
    }
}

extension InternetAddress {
    
    func resolve(with config: SocketConfig) throws -> ResolvedInternetAddress {
        return try Resolver(config: config).resolve(internetAddress: self)
    }
}

public class ResolvedInternetAddress {
    
    let raw: UnsafeMutablePointer<sockaddr>
    
    init(raw: sockaddr){
        let ptr = UnsafeMutablePointer<sockaddr>.init(allocatingCapacity: 1)
        ptr.initialize(with: raw)
        self.raw = ptr
    }

    var rawLen: socklen_t {
        return socklen_t(sizeof(sockaddr))
    }
    
    public func addressFamily() throws -> AddressFamily {
        return try AddressFamily(fromCType: Int32(raw.pointee.sa_family))
    }
    
    public func ipString() -> String {
        
        guard let family = try? addressFamily() else { return "Invalid family" }
        let cfamily = family.toCType()
        
        let maxLen = socklen_t(INET_ADDRSTRLEN)
        let strData = UnsafeMutablePointer<Int8>.init(allocatingCapacity: Int(maxLen))
        
        switch family {
        case .inet:
            var ptr = UnsafeMutablePointer<sockaddr_in>(raw).pointee.sin_addr
            inet_ntop(cfamily, &ptr, strData, maxLen)
        case .inet6:
            var ptr = UnsafeMutablePointer<sockaddr_in6>(raw).pointee.sin6_addr
            inet_ntop(cfamily, &ptr, strData, maxLen)
        case .unspecified:
            fatalError("ResolvedInternetAddress should never be unspecified")
        }
        
        guard let str = String(validatingUTF8: strData) else {
            return "Invalid ip string"
        }
        return str
    }

    deinit {
        self.raw.deinitialize(count: 1)
        self.raw.deallocateCapacity(1)
    }
}

extension ResolvedInternetAddress: CustomStringConvertible {
    
    public var description: String {
        return "ResolvedInternetAddress: \(self.ipString())"
    }
}

