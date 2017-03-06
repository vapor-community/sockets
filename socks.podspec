Pod::Spec.new do |s|
  s.name = "socks"
  s.version = '1.2.2'

  s.source = {
    :git => "https://github.com/banxi1988/socks.git",
    :tag => s.version,
  }

  s.license = 'MIT'
  s.summary = 'Pure-Swift Sockets: TCP, UDP; Client, Server; Linux, OS X'
  s.homepage = 'http://docs.vapor.codes'
  s.description = 'Pure-Swift Sockets: TCP, UDP; Client, Server; Linux, OS X,The package provides two libraries: SocksCore and Socks'
  s.authors  = { 'Vapor' => 'vapor@vapor.codes' }
  s.documentation_url = 'http://docs.vapor.codes'
  s.default_subspecs = 'SocksCore', 'Socks'
  s.requires_arc = true
  s.pod_target_xcconfig = {
    'SWIFT_VERSION' => '3.0',
  }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'

  s.subspec 'SocksCore' do |ss|
    ss.source_files = 'Sources/SocksCore/*.swift'
  end

  s.subspec 'Socks' do |ss|
    ss.source_files = 'Sources/Socks/*.swift'
    ss.dependency 'socks/SocksCore'
  end
end
