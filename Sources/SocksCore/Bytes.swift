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

let BufferCapacity = 512

class Bytes {
    
    let rawBytes: UnsafeMutablePointer<UInt8>
    let capacity: Int
    
    init(capacity: Int = BufferCapacity) {
        self.rawBytes = UnsafeMutablePointer<UInt8>(malloc(capacity + 1))
        //add null strings terminator at location 'capacity'
        //so that whatever we receive, we always terminate properly when converting to a string?
        //otherwise we might overread and read garbage, potentially opening a security hole.
        self.rawBytes[capacity] = UInt8(0)
        self.capacity = capacity
    }
    
    deinit {
        free(self.rawBytes)
    }
    
    var characters: [CChar] {
        var data = [CChar](repeating: 0, count: self.capacity)
        memcpy(&data, self.rawBytes, data.count)
        return data
    }
    
    func toString() throws -> String {
        return try self.characters.toString()
    }
}

extension Collection where Iterator.Element == CChar {
    
    public func toString() throws -> String {
        let selfArray = Array(self) + [0]
        guard let string = String(validatingUTF8: selfArray) else {
            throw Error(.UnparsableBytes)
        }
        return string
    }
}

extension Collection where Iterator.Element == UInt8 {
    
    public func toString() throws -> String {
        return try self.map { CChar($0) }.toString()
    }
}



