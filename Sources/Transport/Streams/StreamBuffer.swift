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

    /// create a buffer steam with a chunk size
    public init(_ stream: Stream, size: Int = 2048) {
        self.size = size
        self.stream = stream

        readIterator = Bytes().makeIterator()
        writeBuffer = []
    }

    /// Reads the next byte from the buffer
    public func readByte() throws -> Byte? {
        guard let next = readIterator.next() else {
            readIterator = try stream.read(max: size).makeIterator()
            return readIterator.next()
        }
        return next
    }

    /// reads a chunk of bytes from the buffer
    /// less than max
    public func read(max: Int) throws -> Bytes {
        var bytes = readIterator.array

        // while the byte count is below max
        // continue fetching, until the stream is empty
        while bytes.count < max {
            let new = try stream.read(max: size)
            bytes += new
            if new.count < size {
                break
            }
        }

        // if byte count is below max,
        // set that as the cap
        let cap = bytes.count > max
            ? max
            : bytes.count

        // pull out the result array
        let result = bytes[0..<cap].array

        if cap >= bytes.count {
            // if returning all bytes, 
            // create empty iterator
            readIterator = [].makeIterator()
        } else {
            // if not returning all bytes,
            // create an iterator with remaining
            let remaining = bytes[cap..<bytes.count]
            readIterator = remaining
                .array
                .makeIterator()
        }

        // return requested bytes
        return result
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
