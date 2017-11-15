public protocol ServerStream: InternetStream, Stream {
    associatedtype Client: DuplexStream, InternetStream
    func bind() throws
    func listen(max: Int) throws
    func accept() throws -> Client
}
