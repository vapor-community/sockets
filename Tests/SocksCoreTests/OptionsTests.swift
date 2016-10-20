//
//  OptionsTests.swift
//  Socks
//
//  Created by Andreas Ley on 20.10.16.
//
//

import XCTest
@testable import SocksCore

class OptionsTests: XCTestCase {
    
    func testSocketOptions() throws {
        let (read, _) = try TCPEstablishedSocket.pipe()
        
        try read.setReuseAddress(true)
        let reuseAddress = try read.getReuseAddress()
        XCTAssert(reuseAddress == true)
        
        try read.setKeepAlive(true)
        let keepAlive = try read.getKeepAlive()
        XCTAssert(keepAlive == true)
        
        let expectedTimeout = timeval(seconds: 0.987)
        
        try read.setSendingTimeout(expectedTimeout)
        let sendingTimeout = try read.getSendingTimeout()
        XCTAssert(sendingTimeout == expectedTimeout)
        
        try read.setReceivingTimeout(expectedTimeout)
        let receivingTimeout = try read.getReceivingTimeout()
        XCTAssert(receivingTimeout == expectedTimeout)
    }
    
    func testReadingSocketOptionOnClosedSocket() throws {
        let (read, _) = try TCPEstablishedSocket.pipe()
        try read.close()
        do {
            _ = try read.getSendingTimeout()
        }
        catch let error as SocksError {
            guard case ErrorReason.optionGetFailed(level: SOL_SOCKET, name: SO_SNDTIMEO, type: "timeval") = error.type else {
                XCTFail()
                return
            }
        }
        catch {
            XCTFail("Wrong error")
        }
        
    }
}
