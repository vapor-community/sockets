public protocol ClientStream: InternetStream, DuplexStream {
    func connect() throws
}
