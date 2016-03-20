
import SocksCore

// higher level utilities using SocksCore

public protocol Actor {
    
    /// Gets called repeatedly, implementation should lazily cache this
    /// socket and not create a new one on each call.
    func getSocket() throws -> Socket
    
    /// Read up to `maxBytes` bytes of data.
    /// Returns an empty array if no data is to be read.
    func read(maxBytes: Int) throws -> [UInt8]
    
    /// Writes the passed-in data into the socket and ensures
    /// all has been submitted, throws otherwise.
    func write(data: [UInt8]) throws
}

public protocol Client: Actor {
}

public protocol Server: Actor {
    
    /// See Actor.getSocket() for rules how to implement this, difference
    /// is that the socket has to be setup already. Calling this before
    /// calling `setup()` below is an API violation.
    func getServerSocket() throws -> ServerSocket
    
    /// Sets up the server for listening, call once before server should
    /// start.
    func setup() throws
    
    /// Waits for a client connection request, then returns the client
    /// to be handled. Call `close()` after all events have been handled.
    func accept() throws -> Actor
}


