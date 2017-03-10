#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

import Bits

// Buffer capacity is the same as the maximum UDP packet size
public let BufferCapacity = 65_507

final class Bytes {
    
    let rawBytes: UnsafeMutablePointer<UInt8>
    let capacity: Int
    
    init(capacity: Int = BufferCapacity) {
        self.rawBytes = UnsafeMutablePointer<UInt8>.allocate(capacity: capacity + 1)
        //add null strings terminator at location 'capacity'
        //so that whatever we receive, we always terminate properly when converting to a string?
        //otherwise we might overread and read garbage, potentially opening a security hole.
        self.rawBytes[capacity] = UInt8(0)
        self.capacity = capacity
    }
    
    deinit {
        free(self.rawBytes)
    }
    
    var characters: [UInt8] {
        var data = [UInt8](repeating: 0, count: self.capacity)
        memcpy(&data, self.rawBytes, data.count)
        return data
    }
    
    func toString() throws -> String {
        return self.characters.string
    }
}
