//
//  XCTestManifests.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

extension AddressResolutionTests {
    static var allTests : [(String, (AddressResolutionTests) -> () throws -> Void)] {
        return [
            ("testResolutionCrashFixed", testResolutionCrashFixed)
        ]
    }
}

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
            ("testLive_HTTP_Get_Google_ipV4", testLive_HTTP_Get_Google_ipV4)
        ]
    }
}

extension PipeTests {
    static var allTests : [(String, (PipeTests) -> () throws -> Void)] {
        return [
            ("testSendAndReceive", testSendAndReceive),
            ("testNoData", testNoData),
            ("testNoSIGPIPE", testNoSIGPIPE)
        ]
    }
}

