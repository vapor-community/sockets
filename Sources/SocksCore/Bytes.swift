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

public struct Bytes4 {

    public let raw: (UInt8, UInt8, UInt8, UInt8)

    public init(raw: (UInt8, UInt8, UInt8, UInt8)) {
        self.raw = raw
    }

    public static func fromArray(array a: [UInt8]) -> Bytes4 {
        assert(a.count == 4, "Array must have exactly 4 elements")
        return Bytes4(raw: (a[0], a[1], a[2], a[3]))
    }

    func toArray() -> [UInt8] {
        return [raw.0, raw.1, raw.2, raw.3]
    }
}

struct Bytes14 {
    let raw: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)

    static func fromArray(array a: [UInt8]) -> Bytes14 {
        assert(a.count == 14, "Array must have exactly 14 elements")
        return Bytes14(raw: (a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10], a[11], a[12], a[13]))
    }
}

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
        let string = String(cString:selfArray)
        return string
    }

}

extension Collection where Iterator.Element == UInt8 {

    public func toString() throws -> String {
        return try self.map { CChar($0) }.toString()
    }

}
