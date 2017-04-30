import Core
import Dispatch

/// Buffers receive and send calls to a Stream.
///
/// Receive calls are buffered by the size used to initialize
/// the buffer.
///
/// Send calls are buffered until `flush()` is called.
public final class StreamBuffer<Stream: DuplexStream>: WriteableStream {
    private let stream: Stream
    private var writeBuffer: Bytes

    public var isClosed: Bool {
        return stream.isClosed
    }

    public func setTimeout(_ timeout: Double) throws {
        try stream.setTimeout(timeout)
    }

    public func close() throws {
        try stream.close()
    }

    /// create a buffer steam with a chunk size
    public init(_ stream: Stream, size: Int = 2048) {
        self.stream = stream
        writeBuffer = []
    }

    /// write bytes to the buffer stream
    public func write(_ bytes: Bytes) throws {
        writeBuffer += bytes
    }

    public func flush() throws {
        guard !writeBuffer.isEmpty else { return }
        try stream.write(writeBuffer)
        try stream.flush()
        writeBuffer = []
    }
}
