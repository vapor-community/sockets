import libc

public protocol InternetSocket: Socket {
    var addresses: [ResolvedInternetAddress] { get }
}

extension InternetSocket {
    public func bind() throws {
        
        var res: Int32 = -1
        
        for address in addresses {
            res = libc.bind(
                descriptor.raw,
                address.raw,
                address.rawLen
            )
            if res > -1 {
                break
            }
        }
   

        guard res > -1 else {
            throw SocketsError(.bindFailed)
        }
    }
}
