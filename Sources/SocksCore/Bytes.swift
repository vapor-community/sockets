//
//  Bytes.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

struct Bytes14 {
    let raw: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)
    
    static func fromArray(array a: [UInt8]) -> Bytes14 {
        assert(a.count == 14, "Array must have exactly 14 elements")
        return Bytes14(raw: (a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10], a[11], a[12], a[13]))
    }
}

struct Bytes4 {
    let raw: (UInt8, UInt8, UInt8, UInt8)
    
    static func fromArray(array a: [UInt8]) -> Bytes4 {
        assert(a.count == 4, "Array must have exactly 4 elements")
        return Bytes4(raw: (a[0], a[1], a[2], a[3]))
    }
    
    func toArray() -> [UInt8] {
        return [raw.0, raw.1, raw.2, raw.3]
    }
}

