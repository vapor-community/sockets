//
//  InternetSocket.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

#if os(Linux)
    import Glibc
    private let socket_bind = Glibc.bind
#else
    import Darwin
    private let socket_bind = Darwin.bind
#endif

public protocol InternetSocket: Socket {
    var address: ResolvedInternetAddress { get }
    
    init(descriptor: Descriptor?, config: SocketConfig, address: ResolvedInternetAddress) throws
}

extension InternetSocket {
    
    public func bind() throws {
        let res = socket_bind(self.descriptor, address.raw, address.rawLen)
        guard res > -1 else { throw SocksError(.bindFailed) }
    }
}
