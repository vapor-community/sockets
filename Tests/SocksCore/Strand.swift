// The MIT License (MIT)

// Copyright (c) 2016 James Richard

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

//Using Strand for now, switch to Dispatch whenever it's bundled into
//Linux toolchains

#if os(Linux)
import Glibc
#else
import Darwin.C
#endif

public enum StrandError: ErrorProtocol {
    case threadCreationFailed
    case threadCancellationFailed(Int)
    case threadJoinFailed(Int)
}

public class Strand {
    #if os(Linux)
        private var pthread: pthread_t = 0
    #else
        private var pthread: pthread_t?
    #endif

    public init(closure: () -> Void) throws {
        let holder = Unmanaged.passRetained(StrandClosure(closure: closure))
        let pointer = UnsafeMutablePointer<Void>(holder.toOpaque())

        #if os(Linux)
            guard pthread_create(&pthread, nil, runner, pointer) == 0 else {
                holder.release()
                throw StrandError.threadCreationFailed
            }
        #else
            guard pthread_create(&pthread, nil, runner, pointer) == 0 else {
                holder.release()
                throw StrandError.threadCreationFailed
            }
        #endif
    }

    public func join() throws {
        let status = pthread_join(pthread, nil)
        if status != 0 {
            throw StrandError.threadJoinFailed(Int(status))
        }
    }

    public func cancel() throws {
        let status = pthread_cancel(pthread)
        if status != 0 {
            throw StrandError.threadCancellationFailed(Int(status))
        }
    }

    public class func exit(code: inout Int) {
        pthread_exit(&code)
    }

    deinit {
        pthread_detach(pthread)
    }
}

private func runner(arg: UnsafeMutablePointer<Void>?) -> UnsafeMutablePointer<Void>? {
    guard let arg = arg else { return nil }
    let unmanaged = Unmanaged<StrandClosure>.fromOpaque(arg)
    unmanaged.takeUnretainedValue().closure()
    unmanaged.release()
    return nil
}

private class StrandClosure {
    let closure: () -> Void

    init(closure: () -> Void) {
        self.closure = closure
    }
}