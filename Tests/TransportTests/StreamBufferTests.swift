import Foundation
import XCTest

import Core
import Transport

class StreamBufferTests: XCTestCase {
    static let allTests = [
        ("testStreamBufferSending", testStreamBufferSending),
        ("testStreamBufferSendingImmediateFlush", testStreamBufferSendingImmediateFlush),
        ("testStreamBufferReceiving", testStreamBufferReceiving),
        ("testStreamBufferSkipEmpty", testStreamBufferSkipEmpty),
        ("testStreamBufferFlushes", testStreamBufferFlushes),
        ("testStreamBufferMisc", testStreamBufferMisc)
    ]

    var testStream: TestStream!
    var streamBuffer: StreamBuffer<TestStream>!

    override func setUp() {
        testStream = TestStream()
        streamBuffer = StreamBuffer(testStream)
    }

    override func tearDown() {
        super.tearDown()
        // reset
        testStream = nil
        streamBuffer = nil
    }

    func testStreamBufferSending() throws {
        try streamBuffer.write([1,2,3,4,5])
        XCTAssert(testStream.buffer == [], "underlying shouldn't have sent bytes yet")
        try streamBuffer.flush()
        XCTAssert(testStream.buffer == [1,2,3,4,5], "buffer should have sent bytes")
    }

    func testStreamBufferSendingImmediateFlush() throws {
        try streamBuffer.write([1,2,3,4,5], flushing: true)
        XCTAssert(testStream.buffer == [1,2,3,4,5], "buffer should have sent bytes")
    }

    func testStreamBufferReceiving() throws {
        // loads test stream
        try testStream.write([1,2,3,4,5])

        let first = try streamBuffer.readByte()
        XCTAssert(first == 1)
        XCTAssert(testStream.buffer == [], "test stream should be entirely received by buffer")

        let remaining = try streamBuffer.read(max: 200)
        XCTAssert(remaining == [2,3,4,5])
    }

    func testStreamBufferSkipEmpty() throws {
        try streamBuffer.write([], flushing: true)
        XCTAssert(testStream.flushedCount == 0, "should not attempt to flush empty buffer")
    }

    func testStreamBufferFlushes() throws {
        try streamBuffer.write(1)
        try streamBuffer.flush()
        XCTAssert(testStream.flushedCount == 1, "should have flushed")
    }

    func testStreamBufferMisc() throws {
        try streamBuffer.close()
        XCTAssert(testStream.isClosed, "stream buffer should close underlying stream")
        XCTAssert(streamBuffer.isClosed, "stream buffer should reflect closed status of underlying stream")

        try streamBuffer.setTimeout(42)
        XCTAssert(testStream.timeout == 42, "stream buffer should set underlying timeout")
    }

    func testLarge() throws {
        let testStream = TestStream()
        let bytes = Bytes(repeating: .A, count: 65_536)
        try testStream.write(bytes)
        let buffer = StreamBuffer(testStream, size: 5)
        
        for i in 0..<32 {
            let stuff = try buffer.read(max: 2048)
            XCTAssertEqual(stuff.count, 2048, "Failed on iteratior \(i)")
        }

        let zero = try buffer.readByte()
        XCTAssertNil(zero)
    }
}


final class TestStream: DuplexStream {
    var peerAddress: String = "1.2.3.4:5678"

    var isClosed: Bool
    var buffer: Bytes
    var timeout: Double = -1
    // number of times flush was called
    var flushedCount = 0

    func setTimeout(_ timeout: Double) throws {
        self.timeout = timeout
    }

    init() {
        isClosed = false
        buffer = []
    }

    func close() throws {
        if !isClosed {
            isClosed = true
        }
    }

    func write(_ bytes: Bytes) throws {
        isClosed = false
        buffer += bytes
    }

    func flush() throws {
        flushedCount += 1
    }

    func read(max: Int) throws -> Bytes {
        if buffer.count == 0 {
            try close()
            return []
        }

        if max >= buffer.count {
            try close()
            let data = buffer
            buffer = []
            return data
        }

        let data = buffer[0..<max]
        buffer.removeFirst(max)
        
        return Bytes(data)
    }
}
