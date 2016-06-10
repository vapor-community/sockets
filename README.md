# Socks

[![Build Status](https://travis-ci.org/czechboy0/Socks.svg?branch=master)](https://travis-ci.org/czechboy0/Socks)
![Platforms](https://img.shields.io/badge/platforms-Linux%20%7C%20OS%20X-blue.svg)
![Package Managers](https://img.shields.io/badge/package%20managers-swiftpm-yellow.svg)

[![Twitter Czechboy0](https://img.shields.io/badge/twitter-czechboy0-green.svg)](http://twitter.com/czechboy0)
[![Twitter matthiaskr1](https://img.shields.io/badge/twitter-matthiaskr1-green.svg)](http://twitter.com/matthiaskr1)

> Pure-Swift Sockets. Linux & OS X ready.

# Supported socket types

| | TCP | UDP |
| --- | --- | --- |
| Client | ✅ | ✅ | 
| Server | ✅ | ✅ |

# Installation

## Swift Package Manager

```swift
.Package(url: "https://github.com/czechboy0/Socks.git", majorVersion: 0, minor: 5)
```

:wrench: Usage
------------
The package provides two libraries: `SocksCore` and `Socks`.
- `SocksCore` is just a Swift wrapper of the Berkeley sockets API with minimal differences. It is meant to be an easy way to use the low level API without having to deal with Swift/C interop.
- `Socks` is a library providing common usecases built on top of `SocksCore` - a simple `TCPClient`, `SynchronousTCPServer` etc.

If you're building a HTTP server, you'll probably want to use the `TCPClient`, without having to worry about its implementation details. However, if you need the low-level sockets API, just import `SocksCore` and use that instead.

:game_die: Examples
------------
There are many working examples in this package which build as separate binaries. 
- TCP client using SocksCore ([SocksCoreExampleTCPClient](https://github.com/czechboy0/Socks/blob/master/Sources/SocksCoreExampleTCPClient/main.swift))
- TCP server using SocksCore ([SocksCoreExampleTCPServer](https://github.com/czechboy0/Socks/blob/master/Sources/SocksCoreExampleTCPServer/main.swift))
- TCP server that keeps client connections alive using SocksCore ([SocksCoreExampleTCPKeepAliveServer](https://github.com/czechboy0/Socks/blob/master/Sources/SocksCoreExampleTCPKeepAliveServer/main.swift))
- TCP client using Socks ([SocksExampleTCPClient](https://github.com/czechboy0/Socks/blob/master/Sources/SocksExampleTCPClient/main.swift))
- TCP server using Socks ([SocksExampleTCPServer](https://github.com/czechboy0/Socks/blob/master/Sources/SocksExampleTCPServer/main.swift))
- UDP client using Socks ([SocksExampleUDPClient](https://github.com/czechboy0/Socks/blob/master/Sources/SocksExampleUDPClient/main.swift))
- UDP server using Socks ([SocksExampleUDPServer](https://github.com/czechboy0/Socks/blob/master/Sources/SocksExampleUDPServer/main.swift))

:books: Recommended reading
------------
- (1) [TCP/IP Sockets in C: Practical Guide for Programmers](http://www.e-reading.club/bookreader.php/136904/TCP%7CIP_Sockets_in_C:_Practical_Guide_for_Programmers.pdf) (First and Second edition)
- (2) [Wikipedia: Berkeley Sockets](https://en.wikipedia.org/wiki/Berkeley_sockets)

:wrench: Used by
- [Redbird](https://github.com/czechboy0/Redbird) *Pure-Swift implementation of a Redis client from the original protocol spec. OS X + Linux compatible.*
- [Vapor](https://github.com/qutheory/vapor) *A web framework and server for Swift that works on OS X and Ubuntu.*

:blue_heart: Code of Conduct
------------
Please note that this project is released with a [Contributor Code of Conduct](./CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

:gift_heart: Contributing
------------
Please create an issue with a description of your problem or open a pull request with a fix.

:v: License
-------
MIT

:alien: Authors
------
Honza Dvorsky - http://honzadvorsky.com, [@czechboy0](http://twitter.com/czechboy0)  
Matthias Kreileder - [@matthiaskr1](https://twitter.com/matthiaskr1) 
