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
    
}
