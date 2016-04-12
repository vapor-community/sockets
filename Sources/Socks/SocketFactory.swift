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

public class SocketFactory {
    
    /*
 
     public func createTcpClient(hostName : String, port : Port, config) throws -> InternetSocket? {
     
        use InternetAddressResolver to get list of addresses
     
        for each address in this list
        {
            try{
            create RawSocket r
            create InternetAddress i
            create InternetSocket(r,i)
            break since we connected and everyhing is fine 
            }
            catch(...){
                try next address
                continue
            }
     
        }
     
     }
 
 
 
 
    */
 
    
    public init(){
        
    }
    
    public func createAndConnectTcpClientSocket(hostName : String, port : Port) throws -> InternetSocket? {
        
        let socket_Config = SocketConfig(addressFamily: .UNSPECIFIED, socketType: .Stream, protocolType: .TCP)
        // TODO:    This is not beautiful but the port number needs to be string in order to be passed to getaddrinfo()
        //          Extend the type Port to an enum with two cases (one as a string and one as an integer) and write a
        //          toString() method which does the conversion if neccessary
        let portnumber = String(port)
        
        var servinfo = UnsafeMutablePointer<socket_addrinfo>.init(nil)
        servinfo = try! resolveHostnameAndServiceToIPAddresses(socket_Config,
                                                               hostname : hostName,
                                                               service : portnumber)

        
        // Store head to linked list
        var sInfoPtr = servinfo

        while(sInfoPtr != nil){
            // Create a raw socket; try next address in case it doesn't work
            let rawSocket = createRawSocketFromCTypeArguments(sInfoPtr.pointee)

            if (rawSocket.descriptor < 0){
                // Socket creation failed; try next address
                sInfoPtr = sInfoPtr.pointee.ai_next
                continue
            }
            
            
            if (socket_connect(rawSocket.descriptor,sInfoPtr.pointee.ai_addr,sInfoPtr.pointee.ai_addrlen) == 0){
                // Socket connection succeeded
                let addr = InternetAddress(address: .Hostname(hostName), port: port)
                
                let socket = InternetSocket(rawSocket: rawSocket, address: addr)

                // Prevent memory leaks: getaddrinfo creates an unmanaged linked list on the heap
                freeaddrinfo(servinfo)
                
                return socket

            }
            
            // When we reach this line then socket connect failed; try next address
            try! rawSocket.close()
            
            sInfoPtr = sInfoPtr.pointee.ai_next
        }
        
        // If we ever reach this line none of the addresses provided by getaddrinfo() worked :(
        return nil
    }
 
    public func createTcpServerSocket(port : Port) throws -> InternetSocket? {
        
        let socket_Config = SocketConfig(addressFamily: .UNSPECIFIED, socketType: .Stream, protocolType: .TCP)
        // TODO:    This is not beautiful but the port number needs to be string in order to be passed to getaddrinfo()
        //          Extend the type Port to an enum with two cases (one as a string and one as an integer) and write a
        //          toString() method which does the conversion if neccessary
        let portnumber = String(port)
        
        var servinfo = UnsafeMutablePointer<socket_addrinfo>.init(nil)
        servinfo = try! resolveHostnameAndServiceToIPAddresses(socket_Config,
                                                               hostname: "localhost",
                                                               service : portnumber)
        
        // Store head to linked list
        var sInfoPtr = servinfo
        
        while(sInfoPtr != nil){
            // Create a raw socket; try next address in case it doesn't work
            let rawSocket = createRawSocketFromCTypeArguments(sInfoPtr.pointee)
            
            if (rawSocket.descriptor < 0){
                // Socket creation failed; try next address
                sInfoPtr = sInfoPtr.pointee.ai_next
                continue
            }
            
            /*
            if (socket_connect(rawSocket.descriptor,sInfoPtr.pointee.ai_addr,sInfoPtr.pointee.ai_addrlen) == 0){
                // Socket connection succeeded
                let addr = InternetAddress(address: .Hostname(hostName), port: port)
                
                let socket = InternetSocket(rawSocket: rawSocket, address: addr)
                
                // Prevent memory leaks: getaddrinfo creates an unmanaged linked list on the heap
                freeaddrinfo(servinfo)
                
                return socket
                
            }
            */
            
            //let addr = InternetAddress(address: .Hostname("localhost"), port: port)
            //let socket = InternetSocket(rawSocket: raw, address: addr)
            
            // When we reach this line then socket connect failed; try next address
            try! rawSocket.close()
            
            sInfoPtr = sInfoPtr.pointee.ai_next
        }
        
        // If we ever reach this line none of the addresses provided by getaddrinfo() worked :(
        return nil
        
    }
    
    private func createRawSocketFromCTypeArguments(rawSocketCTypeInfo : socket_addrinfo) -> RawSocket{
        // protocol protocolType: Protocol
        var protocolFamily: ProtocolFamily
        if (rawSocketCTypeInfo.ai_family == PF_INET){
            protocolFamily = .Inet
        }
        else{
            protocolFamily = .Inet6
        }
        
        var socketType: SocketType
        if (rawSocketCTypeInfo.ai_socktype == SOCK_STREAM){
            socketType = .Stream
        }
        else{
            socketType = .Datagram
        }
        

        if (rawSocketCTypeInfo.ai_protocol == IPPROTO_TCP){
            let raw = try! RawSocket(protocolFamily: protocolFamily, socketType: socketType, protocol: .TCP)
            return raw
        }
        else{
            let raw = try! RawSocket(protocolFamily: protocolFamily, socketType: socketType, protocol: .UDP)
            return raw
        }

    }
    
}