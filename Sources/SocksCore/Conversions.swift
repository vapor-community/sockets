//
//  Conversions.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

//convert little-endian to big-endian for network transfer
//aka Host TO Network Short
func htons(_ value: CUnsignedShort) -> CUnsignedShort {
    return (value << 8) + (value >> 8)
}

extension Array {
    
    func periodSeparatedString() -> String {
        return self.map { String($0) }.joined(separator: ".")
    }
}

extension String {
    
    public func toBytes() -> [UInt8] {
        return Array(self.utf8)
    }
}

// Sendable
public protocol Sendable {
    func serialize() -> [UInt8]
}

extension String: Sendable {
    public func serialize() -> [UInt8] {
        return self.toBytes()
    }
}


// Receivable
protocol Receivable {
    static func deserialize(reader: (maxBytes: Int) throws -> [UInt8]) throws -> Self
}


extension String: Receivable {
    
    static func deserialize(reader: (maxBytes: Int) throws -> [UInt8]) throws -> String {
        var allBytes: [UInt8] = []
        while true {
            let newBytes = try reader(maxBytes: 1024)
            allBytes += newBytes
            if newBytes.count < 1024 || newBytes.last! == UInt8(0) {
                return try toString(bytes:allBytes)
            }
        }
    }
}

func toString(bytes: [UInt8]) throws -> String {
    
    var utf = UTF8()
    var gen = bytes.makeIterator()
    var str = String()
    while true {
        switch utf.decode(&gen) {
        case .emptyInput: return str
        case .error: throw Error("unparsableBytes")
        case .scalarValue(let unicodeScalar): str.append(unicodeScalar)
        }
    }
}

