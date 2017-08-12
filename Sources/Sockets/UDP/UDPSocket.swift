import libc

public class UDPInternetSocket: InternetSocket {

    public let descriptors: [Descriptor]
    public let configs: [Config]
    public let addresses: [ResolvedInternetAddress]
    public private(set) var isClosed = false

    public required init(descriptors: [Descriptor], configs: [Config], addresses: [ResolvedInternetAddress]) throws {

		
        if descriptors.count == 0 {
			self.descriptors = [try Descriptor(configs[0])]
        } else {
			self.descriptors = descriptors
        }
		
        self.configs = configs
        self.addresses = addresses
    }

    public convenience init(address: InternetAddress) throws {
        var conf: Config = .UDP(addressFamily: address.addressFamily)
        let resolved = try address.resolve(with: &conf)
		var tempAddresses: [ResolvedInternetAddress] = []
		var tempConfigs: [Config] = []
		var tempDescriptors: [Descriptor] = []
 
		for (address, config) in resolved {
			tempAddresses.append(address)
			tempConfigs.append(config)
		}
		
        try self.init(descriptors: [], configs: tempConfigs, addresses: tempAddresses)
    }

    deinit {
        try? self.close()
    }

    public func recvfrom(maxBytes: Int = BufferCapacity) throws -> (data: [UInt8], sender: ResolvedInternetAddress) {
        if isClosed { throw SocketsError(.socketIsClosed) }
        let data = Buffer(capacity: maxBytes)
        let flags: Int32 = 0 //FIXME: allow setting flags with a Swift enum

        var length = socklen_t(MemoryLayout<sockaddr_storage>.size)
        let addr = UnsafeMutablePointer<sockaddr_storage>.allocate(capacity: 1)
        let addrSockAddr = UnsafeMutablePointer<sockaddr>(OpaquePointer(addr))

        let receivedBytes = libc.recvfrom(
            descriptor.raw,
            data.pointer,
            data.capacity,
            flags,
            addrSockAddr,
            &length
        )
        guard receivedBytes > -1 else {
            addr.deallocate(capacity: 1)
            throw SocketsError(.readFailed)
        }

        let clientAddress = ResolvedInternetAddress(raw: addr)

        let finalBytes = data.bytes[0..<receivedBytes]
        let out = Array(finalBytes)
        return (data: out, sender: clientAddress)
    }

    public func sendto(data: [UInt8], address: ResolvedInternetAddress? = nil) throws {
        if isClosed { throw SocketsError(.socketIsClosed) }
        let len = data.count
        let flags: Int32 = 0 //FIXME: allow setting flags with a Swift enum
        guard let destination = address ?? self.addresses.first else {
            throw SocketsError.init(.remoteAddressResolutionFailed)
        }

        let sentLen = libc.sendto(
            descriptor.raw,
            data,
            len,
            flags,
            destination.raw,
            destination.rawLen
        )
        guard sentLen == len else { throw SocketsError(.writeFailed) }
    }

    public func close() throws {
        if isClosed { return }
        isClosed = true
        if libc.close(descriptor.raw) != 0 {
            throw SocketsError(.closeSocketFailed)
        }
    }
}

// MARK: Deprecated
extension UDPInternetSocket {
    @available(*, deprecated, message: "Use `addresses` instead.")
    public var address: ResolvedInternetAddress {
        return addresses[0]
    }
	
	@available(*, deprecated, message: "Use `descriptors` instead.")
	public var descriptor: Descriptor {
		return descriptors[0]
	}
	
	@available(*, deprecated, message: "Use `configs` instead.")
	public var config: Config {
		return configs[0]
	}

    @available(*, deprecated, message: "Use parameter label `addresses` instead.")
    public convenience init(descriptor: Descriptor?, config: Config, address: ResolvedInternetAddress) throws {
		if let descriptor = descriptor {
			try self.init(descriptors: [descriptor], configs: [config], addresses: [address])

		} else {
			try self.init(descriptors: [], configs: [config], addresses: [address])
		}
    }
}
