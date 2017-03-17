#if os(OSX) || os(iOS)
import Foundation

public final class FoundationStream: NSObject, Stream, ClientStream, StreamDelegate {
    public enum Error: Swift.Error {
        case unableToCompleteReadOperation
        case unableToCompleteWriteOperation
        case unableToConnectToHost
        case unableToUpgradeToSSL
    }

    public func setTimeout(_ timeout: Double) throws {}

    public var isClosed: Bool {
        return input.closed
            || output.closed
    }

    // program
    public let scheme: String
    public let hostname: String
    public let port: Port

    let input: InputStream
    let output: OutputStream

    public init(
        scheme: String,
        hostname: String,
        port: Port
    ) throws {
        self.scheme = scheme
        self.hostname = hostname
        self.port = port

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

    public func write(_ bytes: Bytes) throws {
        guard !bytes.isEmpty else { return }
        
        var buffer = bytes
        let written = output.write(&buffer, maxLength: buffer.count)
        guard written == bytes.count else {
            throw Error.unableToCompleteWriteOperation
        }
    }

    public func flush() throws {}

    public func read(max: Int) throws -> Bytes {
        var buffer = Bytes(repeating: 0, count: max)
        let read = input.read(&buffer, maxLength: max)
        guard read != -1 else { throw Error.unableToCompleteReadOperation }
        return buffer.prefix(read).array
    }

    // MARK: Connect

    public func connect() throws {
        input.open()
        output.open()
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
