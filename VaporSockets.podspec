Pod::Spec.new do |s|

  s.name         = "VaporSockets"
  s.version      = "2.0.0"
  s.summary      = "Pure-Swift Sockets: TCP, UDP; Client, Server; Linux, OS X... "

  s.description  = <<-DESC
                  Pure-Swift Sockets: TCP, UDP; Client, Server; Linux, OS X.s.. mirror from vapor/bits for CocoaPods
                   DESC

  s.homepage     = "https://github.com/vapor/sockets"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.authors            = { "vapor" => "vapor@gmai.com" }

  s.ios.deployment_target = "8.0"
  s.tvos.deployment_target = "9.0"
  s.osx.deployment_target = "10.10"
  s.watchos.deployment_target = "2.0"

  s.source       = { :git => "https://github.com/vapor/sockets.git", :tag => '2.0.0-beta.3' }
  
  s.source_files  = ["Sources/Sockets/**/*.swift" ]

  s.dependency 'VaporCoreCore'
  s.dependency 'VaporTransport'
  
  s.requires_arc = true
  # s.framework = "CFNetwork"
  s.module_name = "Sockets"

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '3.1' }
end
