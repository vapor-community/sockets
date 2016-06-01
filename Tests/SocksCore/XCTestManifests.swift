//
//  XCTestManifests.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

extension ConversionTests {
    static var allTests : [(String, (ConversionTests) -> () throws -> Void)] {
        return [
            ("testNumberArrayToPeriodSeparatedString", testNumberArrayToPeriodSeparatedString)
        ]
    }
}

extension LiveTests {
    static var allTests : [(String, (LiveTests) -> () throws -> Void)] {
        return [
            ("testLive_HTTP_Get_Google", testLive_HTTP_Get_Google)
        ]
    }
}

