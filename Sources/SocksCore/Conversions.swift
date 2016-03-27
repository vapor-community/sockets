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

import Cocoa

extension Array {
    
    func periodSeparatedString() -> String {
        let count = self.count
        var str = ""
        for (idx, el) in self.enumerate() {
            str += "\(el)"
            if idx < count - 1 {
                str += "."
            }
        }
        return str
    }
    
    func colonSeparatedString() -> String {

        let count = self.count
        var iteration = 0
        var str = ""
        for hexNumber in self {
            //TODO: Please review this cast
            let subStr = NSString(format:"%4X", hexNumber as! CVarArgType) as String
            str += subStr.lowercaseString
            
            if iteration < count - 1 {
                str += ":"
            }
            iteration += 1
        }
        
        return str
    }
}

extension String {
    
    public func toBytes() -> [UInt8] {
        return Array(self.utf8)
    }
}

