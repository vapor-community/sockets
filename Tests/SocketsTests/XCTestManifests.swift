extension AddressResolutionTests {
    static var allTests : [(String, (AddressResolutionTests) -> () throws -> Void)] {
        return [
            ("testResolutionCrashFixed", testResolutionCrashFixed)
        ]
    }
}

extension ConversionTests {
    static var allTests : [(String, (ConversionTests) -> () throws -> Void)] {
        return [
            ("testNumberArrayToPeriodSeparatedString", testNumberArrayToPeriodSeparatedString)
        ]
    }
}

extension LiveTests {
    static var allTests : [(String, (LiveTests) -> () throws -> Void)] {
        return [
            ("testLive_HTTP_Get_ipV4", testLive_HTTP_Get_ipV4),
            ("testLive_HTTP_Get_ipV4_withTimeout", testLive_HTTP_Get_ipV4_withTimeout)
        ]
    }
}

extension PipeTests {
    static var allTests : [(String, (PipeTests) -> () throws -> Void)] {
        return [
            ("testSendAndReceive", testSendAndReceive),
            ("testNoData", testNoData),
            ("testNoSIGPIPE", testNoSIGPIPE)
        ]
    }
}

extension SelectTests {
    static var allTests : [(String, (SelectTests) -> () throws -> Void)] {
        return [
            ("testEmpties", testEmpties),
            ("testOnePipeReadyToWrite", testOnePipeReadyToWrite),
            ("testOnePipeReadyToReadOneToWrite", testOnePipeReadyToReadOneToWrite),
            ("testTwoPipesReadyToRead", testTwoPipesReadyToRead)
        ]
    }
}

extension TimeoutTests {
    static var allTests : [(String, (TimeoutTests) -> () throws -> Void)] {
        return [
            ("testDefaults", testDefaults),
            ("testReceiveTimeoutTiny", testReceiveTimeoutTiny),
            ("testReceiveTimeoutSmall", testReceiveTimeoutSmall),
            ("testSendTimeoutSmall", testSendTimeoutSmall),
        ]
    }
}

extension LifetimeTests {
    static var allTests : [(String, (LifetimeTests) -> () throws -> Void)] {
        return [
            ("testStoppingTCPInternetSocket", testStoppingTCPInternetSocket),
            ("testStoppingUDPSocket", testStoppingUDPSocket),
            ("testReleasingTCPInternetSocket", testReleasingTCPInternetSocket),
            ("testReleasingUDPInternetSocket", testReleasingUDPInternetSocket)
        ]
    }
}
