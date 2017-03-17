public typealias DuplexProgramStream = ClientStream & ServerStream

public typealias Port = UInt16

public protocol InternetStream {
    var scheme: String { get }
    var hostname: String { get }
    var port: Port { get }
}

extension Int {
    public var port: Port {
        return Port(self % Int(Port.max))
    }
}
