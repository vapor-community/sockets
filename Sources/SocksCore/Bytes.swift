//
//  Bytes.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

// Buffer capacity is the same as the maximum UDP packet size
public let BufferCapacity = 65_507

class Bytes {
    
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
        return try self.characters.toString()
    }
}

extension Collection where Iterator.Element == UInt8 {
    
    public func toString() throws -> String {
        var utf = UTF8()
        var gen = self.makeIterator()
        var chars = String.UnicodeScalarView()
        while true {
            switch utf.decode(&gen) {
            case .emptyInput: //we're done
                return String(chars)
            case .error: //error, can't describe what however
                throw SocksError(.unparsableBytes)
            case .scalarValue(let unicodeScalar):
                chars.append(unicodeScalar)
            }
        }
    }
}



