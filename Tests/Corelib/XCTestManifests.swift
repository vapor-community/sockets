//
//  XCTestManifests.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

extension ConversionTests {
    static var allTests : [(String, ConversionTests -> () throws -> Void)] {
        return [
                   ("testNumberArrayToPeriodSeparatedString", testNumberArrayToPeriodSeparatedString)
        ]
    }
}

