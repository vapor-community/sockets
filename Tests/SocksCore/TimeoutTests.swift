//
//  TimeoutTests.swift
//  Socks
//
//  Created by Honza Dvorsky on 6/9/16.
//
//

import Foundation
import XCTest

@testable import SocksCore

class TimeoutTests: XCTestCase {
    
    // If anyone has an idea of how to test an infinite timeout, I'm all yours :)
    
    func testSmall() throws {
        TODO: test timeouts, both on sending and receiving, will need libdispatch or something to call
        after a delay from another thread

        don't forget to add linux manifests and linuxmain entries
    }
}