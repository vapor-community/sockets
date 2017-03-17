/// Simple representation of an openeable
/// and closeable byte stream
public protocol Stream: class {
    var isClosed: Bool { get }
    func close() throws

    func setTimeout(_ timeout: Double) throws
}


public typealias DuplexStream = ReadableStream & WriteableStream
