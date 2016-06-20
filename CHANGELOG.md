# Change Log

## [Unreleased](https://github.com/czechboy0/Socks/tree/HEAD)

[Full Changelog](https://github.com/czechboy0/Socks/compare/0.7.0...HEAD)

**Closed issues:**

- Add timeout to connect [\#56](https://github.com/czechboy0/Socks/issues/56)
- Add more informative Socket error descriptions [\#47](https://github.com/czechboy0/Socks/issues/47)

**Merged pull requests:**

- TCP connect timeout [\#57](https://github.com/czechboy0/Socks/pull/57) ([czechboy0](https://github.com/czechboy0))
- Implementing a struct called ErrorCodes which serves as a static Dict… [\#54](https://github.com/czechboy0/Socks/pull/54) ([MatthiasKreileder](https://github.com/MatthiasKreileder))

## [0.7.0](https://github.com/czechboy0/Socks/tree/0.7.0) (2016-06-13)
[Full Changelog](https://github.com/czechboy0/Socks/compare/0.6.0...0.7.0)

**Closed issues:**

- Add timeout to send/recv [\#48](https://github.com/czechboy0/Socks/issues/48)
- Wrapping socket functions [\#2](https://github.com/czechboy0/Socks/issues/2)

**Merged pull requests:**

- Added a timeval constructor for Double seconds, reexported timeval from Socks [\#53](https://github.com/czechboy0/Socks/pull/53) ([czechboy0](https://github.com/czechboy0))
- Refactored Resolver [\#52](https://github.com/czechboy0/Socks/pull/52) ([czechboy0](https://github.com/czechboy0))

## [0.6.0](https://github.com/czechboy0/Socks/tree/0.6.0) (2016-06-10)
[Full Changelog](https://github.com/czechboy0/Socks/compare/0.5.0...0.6.0)

**Closed issues:**

- Add Timeout functionality to Socket [\#30](https://github.com/czechboy0/Socks/issues/30)

**Merged pull requests:**

- Send/receive timeouts [\#50](https://github.com/czechboy0/Socks/pull/50) ([czechboy0](https://github.com/czechboy0))
- Bugfixes, refactoring [\#49](https://github.com/czechboy0/Socks/pull/49) ([czechboy0](https://github.com/czechboy0))
- Added a keep alive TCP server example [\#46](https://github.com/czechboy0/Socks/pull/46) ([czechboy0](https://github.com/czechboy0))

## [0.5.0](https://github.com/czechboy0/Socks/tree/0.5.0) (2016-06-08)
[Full Changelog](https://github.com/czechboy0/Socks/compare/0.4.3...0.5.0)

**Closed issues:**

- Don't trap on SIGPIPE [\#37](https://github.com/czechboy0/Socks/issues/37)

**Merged pull requests:**

- Added select\(\) to observe activity on multiple sockets, more tests [\#45](https://github.com/czechboy0/Socks/pull/45) ([czechboy0](https://github.com/czechboy0))
- Refactoring + fixed NOSIGPIPE \(with tests\) [\#44](https://github.com/czechboy0/Socks/pull/44) ([czechboy0](https://github.com/czechboy0))

## [0.4.3](https://github.com/czechboy0/Socks/tree/0.4.3) (2016-06-07)
[Full Changelog](https://github.com/czechboy0/Socks/compare/0.4.2...0.4.3)

**Merged pull requests:**

- Added a way to set socket options [\#42](https://github.com/czechboy0/Socks/pull/42) ([czechboy0](https://github.com/czechboy0))

## [0.4.2](https://github.com/czechboy0/Socks/tree/0.4.2) (2016-06-07)
[Full Changelog](https://github.com/czechboy0/Socks/compare/0.4.1...0.4.2)

**Merged pull requests:**

- Updated to Swift snapshot 06-06, backwards compatible fixes only [\#41](https://github.com/czechboy0/Socks/pull/41) ([czechboy0](https://github.com/czechboy0))

## [0.4.1](https://github.com/czechboy0/Socks/tree/0.4.1) (2016-06-06)
[Full Changelog](https://github.com/czechboy0/Socks/compare/0.4.0...0.4.1)

**Fixed bugs:**

- rare `UnsafeMutablePointer.initializeFrom` error [\#33](https://github.com/czechboy0/Socks/issues/33)

**Closed issues:**

- `closed` property on socket [\#35](https://github.com/czechboy0/Socks/issues/35)
- Make `Port` public in `Socks` module [\#32](https://github.com/czechboy0/Socks/issues/32)

**Merged pull requests:**

- Fixed the intermittent address resolution crash [\#39](https://github.com/czechboy0/Socks/pull/39) ([czechboy0](https://github.com/czechboy0))
- adding close capabilities [\#38](https://github.com/czechboy0/Socks/pull/38) ([LoganWright](https://github.com/LoganWright))
- Re-export public facing enums from SocksCore [\#34](https://github.com/czechboy0/Socks/pull/34) ([czechboy0](https://github.com/czechboy0))

## [0.4.0](https://github.com/czechboy0/Socks/tree/0.4.0) (2016-06-02)
[Full Changelog](https://github.com/czechboy0/Socks/compare/0.3.1...0.4.0)

**Merged pull requests:**

- Fixed ipv6 address handling [\#31](https://github.com/czechboy0/Socks/pull/31) ([czechboy0](https://github.com/czechboy0))
- General fixes to the workflow, easier usage [\#29](https://github.com/czechboy0/Socks/pull/29) ([czechboy0](https://github.com/czechboy0))

## [0.3.1](https://github.com/czechboy0/Socks/tree/0.3.1) (2016-06-01)
[Full Changelog](https://github.com/czechboy0/Socks/compare/0.3.0...0.3.1)

## [0.3.0](https://github.com/czechboy0/Socks/tree/0.3.0) (2016-06-01)
[Full Changelog](https://github.com/czechboy0/Socks/compare/0.2.3...0.3.0)

**Closed issues:**

- UDP Support [\#21](https://github.com/czechboy0/Socks/issues/21)

**Merged pull requests:**

- UDP Client/Server [\#28](https://github.com/czechboy0/Socks/pull/28) ([czechboy0](https://github.com/czechboy0))
- Updated Swift 05-09 [\#27](https://github.com/czechboy0/Socks/pull/27) ([czechboy0](https://github.com/czechboy0))

## [0.2.3](https://github.com/czechboy0/Socks/tree/0.2.3) (2016-05-06)
[Full Changelog](https://github.com/czechboy0/Socks/compare/0.2.2...0.2.3)

**Closed issues:**

- Fix Resolver's leaking addrinfo list [\#25](https://github.com/czechboy0/Socks/issues/25)

**Merged pull requests:**

- Refactored resolving of addresses, fixed leak [\#26](https://github.com/czechboy0/Socks/pull/26) ([czechboy0](https://github.com/czechboy0))

## [0.2.2](https://github.com/czechboy0/Socks/tree/0.2.2) (2016-05-05)
[Full Changelog](https://github.com/czechboy0/Socks/compare/0.2.1...0.2.2)

## [0.2.1](https://github.com/czechboy0/Socks/tree/0.2.1) (2016-05-03)
[Full Changelog](https://github.com/czechboy0/Socks/compare/0.2.0...0.2.1)

**Closed issues:**

- IPv6 support [\#13](https://github.com/czechboy0/Socks/issues/13)

**Merged pull requests:**

- IPv6 support [\#22](https://github.com/czechboy0/Socks/pull/22) ([MatthiasKreileder](https://github.com/MatthiasKreileder))

## [0.2.0](https://github.com/czechboy0/Socks/tree/0.2.0) (2016-04-14)
[Full Changelog](https://github.com/czechboy0/Socks/compare/0.1.0...0.2.0)

**Closed issues:**

- Carthage [\#19](https://github.com/czechboy0/Socks/issues/19)
- Do you plan to support select ? [\#14](https://github.com/czechboy0/Socks/issues/14)
- Create enums for socket constants [\#1](https://github.com/czechboy0/Socks/issues/1)

**Merged pull requests:**

- Updated to April 24 snapshot [\#20](https://github.com/czechboy0/Socks/pull/20) ([czechboy0](https://github.com/czechboy0))
- Simplified IP address string creation [\#18](https://github.com/czechboy0/Socks/pull/18) ([czechboy0](https://github.com/czechboy0))

## [0.1.0](https://github.com/czechboy0/Socks/tree/0.1.0) (2016-03-29)
[Full Changelog](https://github.com/czechboy0/Socks/compare/0.0.3...0.1.0)

**Merged pull requests:**

- updated for Swift 3, fixes \#15 plus a couple other things [\#16](https://github.com/czechboy0/Socks/pull/16) ([czechboy0](https://github.com/czechboy0))

## [0.0.3](https://github.com/czechboy0/Socks/tree/0.0.3) (2016-03-21)
[Full Changelog](https://github.com/czechboy0/Socks/compare/0.0.2...0.0.3)

## [0.0.2](https://github.com/czechboy0/Socks/tree/0.0.2) (2016-03-21)
[Full Changelog](https://github.com/czechboy0/Socks/compare/0.0.1...0.0.2)

**Closed issues:**

- Pretty TCP client/server [\#12](https://github.com/czechboy0/Socks/issues/12)

## [0.0.1](https://github.com/czechboy0/Socks/tree/0.0.1) (2016-03-20)
**Closed issues:**

- Basic TCP Server [\#10](https://github.com/czechboy0/Socks/issues/10)
- Get minimal TCP client working [\#7](https://github.com/czechboy0/Socks/issues/7)
- Address handling [\#3](https://github.com/czechboy0/Socks/issues/3)

**Merged pull requests:**

- TCP Server [\#11](https://github.com/czechboy0/Socks/pull/11) ([czechboy0](https://github.com/czechboy0))
- Adding enums: DGRAM and UDP [\#9](https://github.com/czechboy0/Socks/pull/9) ([MatthiasKreileder](https://github.com/MatthiasKreileder))
- TCP Client [\#8](https://github.com/czechboy0/Socks/pull/8) ([czechboy0](https://github.com/czechboy0))
- Initial Address work, added minimum of basic types [\#6](https://github.com/czechboy0/Socks/pull/6) ([czechboy0](https://github.com/czechboy0))
- Added xcodeproj, stubbed Corelib file hierarchy [\#5](https://github.com/czechboy0/Socks/pull/5) ([czechboy0](https://github.com/czechboy0))



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*