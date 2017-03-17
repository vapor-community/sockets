import Dispatch
import libc

public protocol TCPSocket: RawSocket { }

public typealias TCPDuplexSocket = TCPReadableSocket & TCPWriteableSocket
