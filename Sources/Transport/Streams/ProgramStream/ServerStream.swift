public protocol ServerStream: ProgramStream {
    func bind() throws
    func listen(max: Int) throws 
    func accept() throws -> Self
}
