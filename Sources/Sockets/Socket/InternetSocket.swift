import libc

public protocol InternetSocket: Socket {
    var address: ResolvedInternetAddress { get }
}

extension InternetSocket {
    public func bind() throws {
        let res = libc.bind(
            descriptor.raw,
            address.raw,
            address.rawLen
        )

        guard res > -1 else {
            throw SocketsError(.bindFailed)
        }
    }
}
