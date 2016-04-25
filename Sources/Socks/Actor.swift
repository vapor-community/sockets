//
//  Actor.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

extension Actor {
    
    public func close() throws {
        try self.getSocket().close()
    }
    
    public func read(maxBytes: Int) throws -> [UInt8] {
        return try self.getSocket().recv(maxBytes: maxBytes)
    }
    
    public func write(data: [UInt8]) throws {
        try self.getSocket().send(data: data)
    }
    
    public func readAll() throws -> [UInt8] {
        var buffer: [UInt8] = []
        let chunkSize = 512
        while true {
            let newData = try self.read(maxBytes: chunkSize)
            buffer.append(contentsOf: newData)
            if newData.count < chunkSize {
                break
            }
        }
        return buffer
    }
    
    public func write(data: String) throws {
        try self.write(data: data.toBytes())
    }
}