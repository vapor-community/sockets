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

#if os(Linux)
import Glibc
#else
import Darwin
#endif


func fdZero(_ set: inout fd_set) {
#if os(Linux)
#if arch(arm)
  set.__fds_bits = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
#else
  set.__fds_bits = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
#endif
#else
  set.fds_bits = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
#endif
}


func fdSet(_ descriptor: Descriptor, _ set: inout fd_set) {
#if os(Linux)
  let intOffset = Int(descriptor / 16)
  let bitOffset = Int(descriptor % 16)
  let mask = 1 << bitOffset
  switch intOffset {
    case 0: set.__fds_bits.0 = set.__fds_bits.0 | mask
    case 1: set.__fds_bits.1 = set.__fds_bits.1 | mask
    case 2: set.__fds_bits.2 = set.__fds_bits.2 | mask
    case 3: set.__fds_bits.3 = set.__fds_bits.3 | mask
    case 4: set.__fds_bits.4 = set.__fds_bits.4 | mask
    case 5: set.__fds_bits.5 = set.__fds_bits.5 | mask
    case 6: set.__fds_bits.6 = set.__fds_bits.6 | mask
    case 7: set.__fds_bits.7 = set.__fds_bits.7 | mask
    case 8: set.__fds_bits.8 = set.__fds_bits.8 | mask
    case 9: set.__fds_bits.9 = set.__fds_bits.9 | mask
    case 10: set.__fds_bits.10 = set.__fds_bits.10 | mask
    case 11: set.__fds_bits.11 = set.__fds_bits.11 | mask
    case 12: set.__fds_bits.12 = set.__fds_bits.12 | mask
    case 13: set.__fds_bits.13 = set.__fds_bits.13 | mask
    case 14: set.__fds_bits.14 = set.__fds_bits.14 | mask
    case 15: set.__fds_bits.15 = set.__fds_bits.15 | mask
    default: break
  }
#else
  let intOffset = Int32(descriptor / 16)
  let bitOffset = Int32(descriptor % 16)
  let mask: Int32 = 1 << bitOffset

  switch intOffset {
    case 0: set.fds_bits.0 = set.fds_bits.0 | mask
    case 1: set.fds_bits.1 = set.fds_bits.1 | mask
    case 2: set.fds_bits.2 = set.fds_bits.2 | mask
    case 3: set.fds_bits.3 = set.fds_bits.3 | mask
    case 4: set.fds_bits.4 = set.fds_bits.4 | mask
    case 5: set.fds_bits.5 = set.fds_bits.5 | mask
    case 6: set.fds_bits.6 = set.fds_bits.6 | mask
    case 7: set.fds_bits.7 = set.fds_bits.7 | mask
    case 8: set.fds_bits.8 = set.fds_bits.8 | mask
    case 9: set.fds_bits.9 = set.fds_bits.9 | mask
    case 10: set.fds_bits.10 = set.fds_bits.10 | mask
    case 11: set.fds_bits.11 = set.fds_bits.11 | mask
    case 12: set.fds_bits.12 = set.fds_bits.12 | mask
    case 13: set.fds_bits.13 = set.fds_bits.13 | mask
    case 14: set.fds_bits.14 = set.fds_bits.14 | mask
    case 15: set.fds_bits.15 = set.fds_bits.15 | mask
    default: break
  }
#endif
}


func fdIsSet(_ descriptor: Descriptor, _ set: inout fd_set) -> Bool {
#if os(Linux)
  let intOffset = Int(descriptor / 32)
  let bitOffset = Int(descriptor % 32)
  let mask = Int(1 << bitOffset)

  switch intOffset {
    case 0: return set.__fds_bits.0 & mask != 0
    case 1: return set.__fds_bits.1 & mask != 0
    case 2: return set.__fds_bits.2 & mask != 0
    case 3: return set.__fds_bits.3 & mask != 0
    case 4: return set.__fds_bits.4 & mask != 0
    case 5: return set.__fds_bits.5 & mask != 0
    case 6: return set.__fds_bits.6 & mask != 0
    case 7: return set.__fds_bits.7 & mask != 0
    case 8: return set.__fds_bits.8 & mask != 0
    case 9: return set.__fds_bits.9 & mask != 0
    case 10: return set.__fds_bits.10 & mask != 0
    case 11: return set.__fds_bits.11 & mask != 0
    case 12: return set.__fds_bits.12 & mask != 0
    case 13: return set.__fds_bits.13 & mask != 0
    case 14: return set.__fds_bits.14 & mask != 0
    case 15: return set.__fds_bits.15 & mask != 0
    default: return false
  }
#else
  let intOffset = Int32(descriptor / 32)
  let bitOffset = Int32(descriptor % 32)
  let mask = Int32(1 << bitOffset)

  switch intOffset {
    case 0: return set.fds_bits.0 & mask != 0
    case 1: return set.fds_bits.1 & mask != 0
    case 2: return set.fds_bits.2 & mask != 0
    case 3: return set.fds_bits.3 & mask != 0
    case 4: return set.fds_bits.4 & mask != 0
    case 5: return set.fds_bits.5 & mask != 0
    case 6: return set.fds_bits.6 & mask != 0
    case 7: return set.fds_bits.7 & mask != 0
    case 8: return set.fds_bits.8 & mask != 0
    case 9: return set.fds_bits.9 & mask != 0
    case 10: return set.fds_bits.10 & mask != 0
    case 11: return set.fds_bits.11 & mask != 0
    case 12: return set.fds_bits.12 & mask != 0
    case 13: return set.fds_bits.13 & mask != 0
    case 14: return set.fds_bits.14 & mask != 0
    case 15: return set.fds_bits.15 & mask != 0
    case 16: return set.fds_bits.16 & mask != 0
    case 17: return set.fds_bits.17 & mask != 0
    case 18: return set.fds_bits.18 & mask != 0
    case 19: return set.fds_bits.19 & mask != 0
    case 20: return set.fds_bits.20 & mask != 0
    case 21: return set.fds_bits.21 & mask != 0
    case 22: return set.fds_bits.22 & mask != 0
    case 23: return set.fds_bits.23 & mask != 0
    case 24: return set.fds_bits.24 & mask != 0
    case 25: return set.fds_bits.25 & mask != 0
    case 26: return set.fds_bits.26 & mask != 0
    case 27: return set.fds_bits.27 & mask != 0
    case 28: return set.fds_bits.28 & mask != 0
    case 29: return set.fds_bits.29 & mask != 0
    case 30: return set.fds_bits.30 & mask != 0
    case 31: return set.fds_bits.31 & mask != 0
    default: return false
  }
#endif
}
