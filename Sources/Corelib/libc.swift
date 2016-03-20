//
//  libc.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

#if os(Linux)
    @_exported import Glibc
#else
    @_exported import Darwin
#endif
