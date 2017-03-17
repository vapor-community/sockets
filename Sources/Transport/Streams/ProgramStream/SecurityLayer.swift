public struct SecurityLayer {
    public static let none = SecurityLayer(scheme: "http")

//    public typealias ClientStreamMap = (ClientStream) throws -> ()
//    public typealias ServerStreamMap = (ServerStream) throws -> (DuplexStream)

    public let scheme: String
//    public let connect: ClientStreamMap
//    public let accept: ServerStreamMap

    public init(
        scheme: String
//        connect: @escaping ClientStreamMap = { _ in },
//        accept: @escaping ServerStreamMap = { $0 }
    ) {
        self.scheme = scheme
//        self.connect = connect
//        self.accept = accept
    }
    // case tls(TLS.Context?)
}
