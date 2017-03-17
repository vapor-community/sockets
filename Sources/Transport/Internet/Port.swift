public typealias Port = UInt16

extension Int {
    public var port: Port {
        return Port(self % Int(Port.max))
    }
}
