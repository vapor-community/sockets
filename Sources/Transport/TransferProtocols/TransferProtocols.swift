public protocol TransferMessage: class {}

public protocol TransferParser {
    associatedtype MessageType: TransferMessage
    associatedtype StreamType: DuplexStream
    init(stream: StreamType)
    func parse() throws -> MessageType
}

public protocol TransferSerializer {
    associatedtype MessageType: TransferMessage
    associatedtype StreamType: DuplexStream
    init(stream: StreamType)
    func serialize(_ message: MessageType) throws
}
