//
//  ConversionTests.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

import XCTest
@testable import SocksCore

func eq<T: Equatable>(_ lhs: T, _ rhs: T, file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(lhs, rhs, file: file, line: line)
}

class ConversionTests: XCTestCase {

    func testNumberArrayToPeriodSeparatedString() {
        eq([1,2,3,4].periodSeparatedString(), "1.2.3.4")
        eq([Int]().periodSeparatedString(), "")
        eq([1].periodSeparatedString(), "1")
    }
    
    func testReceivableString() {
        
        var wordToDeserialize = "Hello Socks World"
        
        let myBytes = Array(wordToDeserialize.utf8)
        var gen = myBytes.makeIterator()
        let deserialized = try! String.deserialize { (maxBytes) throws -> [UInt8] in
            var buffer: [UInt8] = []
            while let next = gen.next() {
                buffer.append(next)
                if buffer.count == maxBytes {
                    return buffer
                }
            }
            return buffer
        }
        
        eq(deserialized,wordToDeserialize)
        
    }
    
}
