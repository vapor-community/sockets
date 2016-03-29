//
//  Conversions.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

//convert little-endian to big-endian for network transfer
//aka Host TO Network Short
func htons(value: CUnsignedShort) -> CUnsignedShort {
    return (value << 8) + (value >> 8)
}

extension Array {

    func periodSeparatedString() -> String {
        let count = self.count
        var str = ""
        for (idx, el) in self.enumerated() {
            str += "\(el)"
            if idx < count - 1 {
                str += "."
            }
        }
        return str
    }
}

extension String {

    public func toBytes() -> [UInt8] {
        return Array(self.utf8)
    }
}
