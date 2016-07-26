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

// Sendable and Receivable implementations

extension String: Sendable {
    public func serialize() -> [UInt8] {
        return self.toBytes()
    }
}

extension String: Receivable {
    static func deserialize(reader: (maxBytes: Int) throws -> [UInt8]) throws -> String {
        var allBytes: [UInt8] = []
        let chunkSize = 1024
        while true {
            let newBytes = try reader(maxBytes: chunkSize)
            allBytes += newBytes
            if newBytes.count < chunkSize {
                return try allBytes.toString()
            }
        }
    }
}

