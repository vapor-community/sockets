/// Returned by calls to `Socket.read`
public enum TCPSocketStatus {
    /// The socket read normally.
    /// Note: count == 0 indicates the socket closed.
    case success(count: Int)
    /// The internal socket buffer is empty,
    /// this call would have blocked had this
    /// socket not been set to non-blocking mode.
    ///
    /// Use an event loop to notify you when this socket
    /// is ready to be read from again.
    ///
    /// Note: this is not an error.
    case wouldBlock
}
