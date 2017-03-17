import Core
import Dispatch

/// Buffers receive and send calls to a Stream.
///
/// Receive calls are buffered by the size used to initialize
/// the buffer.
///
/// Send calls are buffered until `flush()` is called.
public final class StreamBuffer<Stream: DuplexStream>: DuplexStream {
    private let stream: Stream
    private let size: Int

    private var readIterator: IndexingIterator<[Byte]>
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

    public init(_ stream: Stream, size: Int = 2048) {
        self.size = size
        self.stream = stream

        readIterator = Bytes().makeIterator()
        writeBuffer = []
    }

    public func readByte() throws -> Byte? {
        guard let next = readIterator.next() else {
            readIterator = try stream.read(max: size).makeIterator()
            return readIterator.next()
        }
        return next
    }

    public func read(max: Int) throws -> Bytes {
        var bytes = readIterator.array

        while bytes.count < max {
            let new = try stream.read(max: size)
            bytes += new
            if new.count < size {
                break
            }
        }

        let cap = bytes.count > max
            ? max
            : bytes.count

        let result = bytes[0..<cap].array

        if cap >= bytes.count {
            readIterator = [].makeIterator()
        } else {
            let remaining = bytes[cap..<bytes.count]
            readIterator = remaining
                .array
                .makeIterator()
        }

        return result
    }

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
