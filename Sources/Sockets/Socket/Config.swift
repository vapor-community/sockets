/// A Config bundels together the information needed to
/// create a socket
public struct Config {
    public var addressFamily: AddressFamily
    public let socketType: SocketType
    public let protocolType: Protocol
    public var reuseAddress: Bool = true

    public init(
        addressFamily: AddressFamily,
        socketType: SocketType,
        protocolType: Protocol
    ) {
        self.addressFamily = addressFamily
        self.socketType = socketType
        self.protocolType = protocolType
    }

    public static func TCP(
        addressFamily: AddressFamily = .unspecified
    ) -> Config {
        return self.init(
            addressFamily: addressFamily,
            socketType: .stream,
            protocolType: .TCP
        )
    }

    public static func UDP(
        addressFamily: AddressFamily = .unspecified
    ) -> Config {
        return self.init(
            addressFamily: addressFamily,
            socketType: .datagram,
            protocolType: .UDP
        )
    }
}
