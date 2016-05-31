//
//  SynchronousServer.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

public class SynchronousServer {
    
    let server: Server
    
    public init(server: Server) {
        self.server = server
    }
    
    @noreturn public func startWithHandler(handler: (connection: Actor) throws -> ()) throws {
        let server = self.server
        try server.setup()
        
        while true {
            let connection = try server.accept()
            try handler(connection: connection)
        }
    }
    
}

