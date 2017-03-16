//import Dispatch
//
//extension TCPInternetSocket: Stream {
//    public var peerAddress: String {
//        let address = self.address
//        guard let addressFamily = try? address.addressFamily() else {
//            return "unknown address family"
//        }
//        switch addressFamily {
//        case .inet:
//            // IPv4: e.g. "10.0.0.141:63234"
//            return "\(address.ipString()):\(address.port)"
//        case .inet6:
//            // IPv6: e.g. "[2001:db8:85a3:8d3:1319:8a2e:370:7348]:443"
//            return "[\(address.ipString())]:\(address.port)"
//        case .unspecified:
//            //input by user, system never resolves an address to .unspecified
//            //ideally, we'd do a quick analysis of whether it's a hostname (treat as IPv4),
//            //or IPv4 literal (treat as IPv4) or IPv6 literal (treat as IPv6).
//            //most common are the first two, for simplicity we'll treat is at IPv4 always for now.
//            return "\(address.ipString()):\(address.port)"
//        }
//    }
//
//    public func setTimeout(_ timeout: Double) throws {
//        let sendingTimeout = timeval(seconds: timeout)
//        try setSendingTimeout(sendingTimeout)
//        try setReceivingTimeout(sendingTimeout)
//    }
//
//    public func send(_ bytes: Core.Bytes) throws {
//        do {
//            try send(data: bytes)
//        } catch {
//            throw StreamError.send("There was a problem while sending data.", error)
//        }
//    }
//
//    public func flush() throws {
//        // flushing is unnecessary, send immediately sends
//    }
//
//    public func receive(max: Int) throws -> Core.Bytes {
//        do {
//            return try recv(maxBytes: max)
//        } catch {
//            throw StreamError.receive("There was a problem while receiving data.", error)
//        }
//    }
//
//    public var closed: Bool {
//        return isClosed
//    }
//}
//
//public class TCPProgramStream: ProgramStream {
//    public let host: String
//    public let port: Int
//    public let securityLayer: SecurityLayer
//    public let stream: TCPInternetSocket
//
//    public required init(host: String, port: Int, securityLayer: SecurityLayer) throws {
//        self.host = host
//        self.port = port
//        self.securityLayer = securityLayer
//
//        let address = InternetAddress(hostname: host, port: Port(port))
//        stream = try TCPInternetSocket(address: address)
//    }
//}

// import TLS

//public var defaultClientConfig: () throws -> TLS.Context = {
//    return try Context(.client, .defaults)
//}

//extension TCPInternetSocket: ClientStream {
//    public var host: String {
//        return address.description
//    }
//
//    public var port: Int {
//        return Int(address.port)
//    }
//
//    public var securityLayer: SecurityLayer {
//        return SecurityLayer.none
//    }
//}
//
//public final class TCPClientStream: TCPProgramStream, ClientStream  {
//    public func connect() throws -> Stream {
//        return try securityLayer.connect(stream)

//        switch securityLayer {
//        case .none:
//            try stream.connect()
//            return stream
//        case .tls(let provided):
//            let config: Context
//            if let c = provided {
//                config = c
//            } else {
//                config = try defaultClientConfig()
//            }
//            let secure = try TLS.Socket(config, stream)
//            try secure.connect(servername: host)
//            return secure
//        }
//    }
//}

//public var defaultServerConfig: () throws -> TLS.Context = {
//    return try Context(.server, .defaults)
//}

//public final class TCPServerStream: TCPProgramStream, ServerStream {
//    public required init(host: String, port: Int, securityLayer: SecurityLayer) throws {
//        try super.init(host: host, port: port, securityLayer: securityLayer)
//
//        try stream.bind()
//        try stream.listen(queueLimit: 4096)
//    }
//
//    deinit {
//        try? stream.close()
//    }
//
//    public func accept() throws -> Stream {
//        switch securityLayer {
//        case .none:
//            return try stream.accept()
//        case .tls(let provided):
//            let config: Context
//            if let c = provided {
//                config = c
//            } else {
//                config = try defaultServerConfig()
//            }
//
//            let secure = try TLS.Socket(config, stream)
//            try secure.accept()
//            return secure
//        }
//    }
//}

//extension TLS.Socket: Stream {
//    public func setTimeout(_ timeout: Double) throws {
//        try socket.setTimeout(timeout)
//    }
//
//    public var closed: Bool {
//        return socket.closed
//    }
//
//    public func flush() throws {
//        try socket.flush()
//    }
//
//    public var peerAddress: String {
//        return currentSocket?.peerAddress ?? socket.peerAddress
//    }
//}
//
//extension SecurityLayer {
//    public var isSecure: Bool {
//        guard case .tls = self else {
//            return false
//        }
//        
//        return true
//    }
//}
