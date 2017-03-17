public enum ProgramStreamError: Error {
    case unsupportedSecurityLayer
}

public typealias DuplexProgramStream = ClientStream & ServerStream

public typealias Port = UInt16

public protocol InternetStream {
    var scheme: String { get }
    var hostname: String { get }
    var port: Port { get }
    init(scheme: String, hostname: String, port: Port) throws
}

extension Int {
    public var port: Port {
        return Port(self % Int(Port.max))
    }
}

extension InternetStream {
    public init() throws {
        try self.init(scheme: "http", hostname: "0.0.0.0", port: 80)
    }

    public init(hostname: String) throws {
        try self.init(scheme: "http", hostname: hostname, port: 80)
    }

    public init(hostname: String, port: Port) throws {
        try self.init(scheme: "http", hostname: hostname, port: port)
    }
}
