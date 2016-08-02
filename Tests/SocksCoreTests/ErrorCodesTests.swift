//
//  ErrorCodesTests.swift
//  Socks
//
//  Created by Matthias Kreileder on 14/06/2016.
//
//

import XCTest
@testable import SocksCore

class ErrorCodesTests: XCTestCase {
    
    func testCornerCases() {
        
        // Outside boundaries
        XCTAssert(ErrorLookUpTable.getCorrespondingErrorString(errorCode: -1) == "?")
        XCTAssert(ErrorLookUpTable.getCorrespondingErrorString(errorCode: ErrorLookUpTable.errorDescriptions.count) == "?")
        // Last element
        XCTAssert(ErrorLookUpTable.getCorrespondingErrorString(errorCode: 124) == "Wrong medium type")
    }
}
