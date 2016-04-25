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

import Foundation

extension Array {
    
    func periodSeparatedString() -> String {
        return self.map { String($0) }.joined(separator: ".")
    }
    /*
    func colonSeparatedString() -> String {

        let count = self.count
        var iteration = 0
        var str = ""
        for hexNumber in self {
            //TODO: Please review this cast
            let subStr = NSString(format:"%4X", hexNumber as! CVarArg) as String
            str += subStr.lowercased()
            
            if iteration < count - 1 {
                str += ":"
            }
            iteration += 1
        }
        
        return str
    }*/
}

extension String {
    
    public func toBytes() -> [UInt8] {
        return Array(self.utf8)
    }
}

