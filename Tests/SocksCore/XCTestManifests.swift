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
                   ("testLive_Connect_Google", testLive_Connect_Google),
                   ("testLive_HTTP_Get_Google", testLive_HTTP_Get_Google)
        ]
    }
}

extension RawSocketTest {
    static var allTests : [(String, (RawSocketTest) -> () throws -> Void)] {
        return [
                   ("testRawSocket", testRawSocket)
        ]
    }
}

extension AddressResolutionTest {
    static var allTests : [(String, (AddressResolutionTest) -> () throws -> Void)] {
        return [
                   ("testResolver", testResolver)
        ]
    }
}

extension ClientSocketTest {
    static var allTests : [(String, (ClientSocketTest) -> () throws -> Void)] {
        return [
                   ("testClientSocket", testClientSocket)
        ]
    }
}


