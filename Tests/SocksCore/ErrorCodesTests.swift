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
        XCTAssert(ErrorLookUpTabel.getCorrespondingErrorString(errorCode: -1) == "?")
        XCTAssert(ErrorLookUpTabel.getCorrespondingErrorString(errorCode: ErrorLookUpTabel.errorDescriptions.count) == "?")
        // Last element
        XCTAssert(ErrorLookUpTabel.getCorrespondingErrorString(errorCode: 124) == "Wrong medium type")
    }
}
