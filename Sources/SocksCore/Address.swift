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

    deinit {
        self.raw.deinitialize(count: 1)
        self.raw.deallocateCapacity(1)
    }
}

