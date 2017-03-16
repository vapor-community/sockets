public enum ProgramStreamError: Error {
    case unsupportedSecurityLayer
}

public typealias DuplexProgramStream = ClientStream & ServerStream

public protocol ProgramStream: DuplexStream {
    var hostname: String { get }
    var port: UInt16 { get }
    var securityLayer: SecurityLayer { get }
    init(hostname: String, port: UInt16, _ securityLayer: SecurityLayer) throws
}

extension ProgramStream {
    public init(hostname: String, port: Int) throws {
        let port = UInt16(port % Int(UInt16.max))
        try self.init(hostname: hostname, port: port, .none)
    }
}

//extension String {
//    public var securityLayer: SecurityLayer {
//        if self == "http" || self == "ws" {
//            return .tls(nil)
//        }
//
//        return .none
//    }
//}
