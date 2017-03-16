#if os(OSX)
import Core
import Foundation

public final class FoundationStream: NSObject, Stream, ClientStream, StreamDelegate {
    public enum Error: Swift.Error {
        case unableToCompleteReadOperation
        case unableToCompleteWriteOperation
        case unableToConnectToHost
        case unableToUpgradeToSSL
    }

    public func setTimeout(_ timeout: Double) throws {
        throw StreamError.unsupported
    }

    public var isClosed: Bool {
        return input.closed
            || output.closed
    }

    public let hostname: String
    public let port: UInt16
    public let securityLayer: SecurityLayer
    let input: InputStream
    let output: OutputStream

    public init(
        hostname: String,
        port: UInt16,
        _ securityLayer: SecurityLayer
    ) throws {
        self.hostname = hostname
        self.port = port
        self.securityLayer = securityLayer

        var inputStream: InputStream? = nil
        var outputStream: OutputStream? = nil
        Foundation.Stream.getStreamsToHost(
            withName: hostname,
            port: Int(port),
            inputStream: &inputStream,
            outputStream: &outputStream
        )
        guard
            let input = inputStream,
            let output = outputStream
            else { throw Error.unableToConnectToHost }
        
        self.input = input
        self.output = output
        super.init()

        self.input.delegate = self
        self.output.delegate = self
    }

    public func close() throws {
        output.close()
        input.close()
    }

    public func send(_ bytes: Bytes) throws {
        guard !bytes.isEmpty else { return }
        
        var buffer = bytes
        let written = output.write(&buffer, maxLength: buffer.count)
        guard written == bytes.count else {
            throw Error.unableToCompleteWriteOperation
        }
    }

    public func flush() throws {}

    public func receive(max: Int) throws -> Bytes {
        var buffer = Bytes(repeating: 0, count: max)
        let read = input.read(&buffer, maxLength: max)
        guard read != -1 else { throw Error.unableToCompleteReadOperation }
        return buffer.prefix(read).array
    }

    // MARK: Connect

    public func connect() throws {
        input.open()
        output.open()
        try securityLayer.connect(self)
    }

    // MARK: Stream Events

    public func stream(_ aStream: Foundation.Stream, handle eventCode: Foundation.Stream.Event) {
        if eventCode.contains(.endEncountered) { _ = try? close() }
    }
}

extension Foundation.Stream {
    var closed: Bool {
        switch streamStatus {
        case .notOpen, .closed:
            return true
        default:
            return false
        }
    }
}
#endif
