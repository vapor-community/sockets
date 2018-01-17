// Copyright (c) 2016, Kyle Fuller
// All rights reserved.

// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:

// * Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer.

// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.

// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import libc

extension timeval {
    public init(seconds: Int) {
        self = timeval(tv_sec: seconds, tv_usec: 0)
    }
    
    public init(seconds: Double) {
        let sec = Int(seconds)
        #if os(Linux)
        let intType = Int.self
        #else
        let intType = Int32.self
        #endif
        let microsec = intType.init((seconds - Double(sec)) * pow(10.0, 6))
        self = timeval(tv_sec: sec, tv_usec: microsec)
    }
}

extension timeval: Equatable { }
public func ==(lhs: timeval, rhs: timeval) -> Bool {
    return lhs.tv_sec == rhs.tv_sec && lhs.tv_usec == rhs.tv_usec
}

private func filter(_ sockets: [Int32]?, _ set: inout fd_set) -> [Int32] {
    return sockets?.filter {
        fdIsSet($0, &set)
        } ?? []
}

public func select(
    reads: [Int32] = [],
    writes: [Int32] = [],
    errors: [Int32] = [],
    timeout: timeval? = nil
) throws -> (reads: [Int32], writes: [Int32], errors: [Int32]) {
        
    var readFDs = fd_set()
    fdZero(&readFDs)
    reads.forEach { fdSet($0, &readFDs) }
    
    var writeFDs = fd_set()
    fdZero(&writeFDs)
    writes.forEach { fdSet($0, &writeFDs) }
    
    var errorFDs = fd_set()
    fdZero(&errorFDs)
    errors.forEach { fdSet($0, &errorFDs) }
    
    let maxFD = (reads + writes + errors).reduce(0, max)
    let result: Int32
    if let timeout = timeout {
        var timeout = timeout
        result = select(maxFD + Int32(1), &readFDs, &writeFDs, &errorFDs, &timeout)
    } else {
        result = select(maxFD + Int32(1), &readFDs, &writeFDs, &errorFDs, nil)
    }
    
    if result == 0 {
        return ([], [], [])
    } else if result > 0 {
        return (
            filter(reads, &readFDs),
            filter(writes, &writeFDs),
            filter(errors, &errorFDs)
        )
    }
    throw SocketsError(.selectFailed(reads: reads, writes: writes, errors: errors))
}

extension RawSocket {
    /// Allows user to wait for the socket to have readable bytes for
    /// up to the specified timeout. Nil timeout means wait forever.
    /// Returns true if data is ready to be read, false if timed out.
    public func waitForReadableData(timeout: timeval?) throws -> Bool {
        let (readables, _, _) = try select(
            reads: [descriptor.raw],
            timeout: timeout
        )
        return !readables.isEmpty
    }
}
