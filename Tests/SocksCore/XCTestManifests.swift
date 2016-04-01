//
//  XCTestManifests.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

extension LiveTests {
    static var allTests : [(String, LiveTests -> () throws -> Void)] {
        return [
                   ("testLive_Connect_Google", testLive_Connect_Google),
                   ("testLive_HTTP_Get_Google", testLive_HTTP_Get_Google)
        ]
    }
}
