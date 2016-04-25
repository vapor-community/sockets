//
//  SocketFactory.swift
//  Socks
//
//  Created by Matthias Kreileder on 28/03/2016.
//
//

import Foundation
import SocksCore

#if os(Linux)
    import Glibc
    typealias socket_addrinfo = Glibc.addrinfo
    private let socket_connect = Glibc.connect
#else
    import Darwin
    typealias socket_addrinfo = Darwin.addrinfo
    private let socket_connect = Darwin.connect
#endif

// DEPRECATED
/*
public class SocketFactory {

    
}
*/