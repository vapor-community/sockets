public protocol ServerStream: ProgramStream {
    func accept() throws -> Self
}
