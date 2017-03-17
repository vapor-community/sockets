public protocol ServerStream: InternetStream {
    associatedtype Client: DuplexStream
    func bind() throws
    func listen(max: Int) throws
    func accept() throws -> Client
}
