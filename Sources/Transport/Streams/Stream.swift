import Core
import Dispatch

public enum StreamError: Error {
    case unsupported
    case send(String, Error)
    case receive(String, Error)
    case custom(String)
}

public protocol Stream: class {
    var isClosed: Bool { get }
    func close() throws

    func setTimeout(_ timeout: Double) throws
}


public typealias DuplexStream = ReadableStream & WriteableStream

public protocol ReadableStream: Stream {
    func receive(max: Int) throws -> Bytes
    // Optional, performance
    func receive() throws -> Byte?
}

extension ReadableStream {
	/// Reads and filters non-valid ASCII characters
    /// from the stream until a new line character is returned.
    public func receiveLine() throws -> Bytes {
        var line: Bytes = []

        var lastByte: Byte? = nil

        while let byte = try receive() {
            // Continues until a `crlf` sequence is found
            if byte == .newLine && lastByte == .carriageReturn {
                break
            }

            // Skip over any non-valid ASCII characters
            if byte > .carriageReturn {
                line += byte
            }

            lastByte = byte
        }

        return line
    }

    /// Default implementation of receive grabs a one
    /// byte array from the stream and returns the first.
    ///
    /// This can be overridden with something more performant.
    public func receive() throws -> Byte? {
        return try receive(max: 1).first
    }
}

public protocol WriteableStream: Stream {
    func send(_ bytes: Bytes) throws
    func flush() throws
}


extension WriteableStream {
    /// Sometimes we let sockets queue things up before flushing, but in situations like web sockets,
    /// we may want to skip that functionality
    public func send(_ bytes: Bytes, flushing: Bool) throws {
        try send(bytes)
        if flushing { try flush() }
    }

    public func send(_ byte: Byte) throws {
        try send([byte])
    }

    public func send(_ string: BytesConvertible) throws {
        try send(try string.makeBytes())
    }

    public func sendLine() throws {
        try send([.carriageReturn, .newLine])
    }
}
