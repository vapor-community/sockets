import libc

import Bits

// Buffer capacity is the same as the maximum UDP packet size
public let BufferCapacity = 65_507

final class Buffer {
    let pointer: UnsafeMutablePointer<UInt8>
    let capacity: Int
    
    init(capacity: Int = BufferCapacity) {
        pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: capacity)
        self.capacity = capacity
    }
    
    deinit {
        free(pointer)
    }
    
    var bytes: Bytes {
        let buffer = UnsafeBufferPointer<Byte>(start: pointer, count: capacity)
        return Bytes(buffer)
    }
}
