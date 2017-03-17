public typealias DuplexProgramStream = ClientStream & ServerStream

public protocol InternetStream {
    var scheme: String { get }
    var hostname: String { get }
    var port: Port { get }
}
