public protocol ServerStream: InternetStream, DuplexStream {
    func bind() throws
    func listen(max: Int) throws 
    func accept() throws -> Self
}
