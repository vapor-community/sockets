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
        return self.map({ String(describing: $0) }).joined(separator: ".")
    }
}

extension String {
    
    public func toBytes() -> [UInt8] {
        return Array(self.utf8)
    }
}

