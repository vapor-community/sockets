Pod::Spec.new do |s|

  s.name         = "VaporCoreCore"
  s.version      = "2.0.0"
  s.summary      = "Core extensions, type-aliases, and functions that facilitate common tasks.. "

  s.description  = <<-DESC
                  Core extensions, type-aliases, and functions that facilitate common tasks.. mirror from vapor/bits for CocoaPods
                   DESC

  s.homepage     = "https://github.com/vapor/core"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.authors            = { "vapor" => "vapor@gmai.com" }

  s.ios.deployment_target = "8.0"
  s.tvos.deployment_target = "9.0"
  s.osx.deployment_target = "10.10"
  s.watchos.deployment_target = "2.0"

  s.source       = { :git => "https://github.com/vapor/core.git", :tag => '2.0.0-beta.3' }
  
  s.source_files  = ["Sources/Core/*.swift" ]

  s.dependency 'VaporCoreLibc'
  s.dependency 'VaporBits'
  s.dependency 'VaporDebugging'
  
  
  s.requires_arc = true
  # s.framework = "CFNetwork"
  s.module_name = "Core"

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '3.1' }
end
