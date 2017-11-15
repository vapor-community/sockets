Pod::Spec.new do |s|

  s.name         = "VaporDebugging"
  s.version      = "1.0.1"
  s.summary      = "A library to aid Vapor users with better debugging around the framework. "

  s.description  = <<-DESC
                  A library to aid Vapor users with better debugging around the framework. mirror from vapor/bits for CocoaPods
                   DESC

  s.homepage     = "https://github.com/vapor/debugging"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.authors            = { "vapor" => "vapor@gmai.com" }

  s.ios.deployment_target = "8.0"
  s.tvos.deployment_target = "9.0"
  s.osx.deployment_target = "10.10"
  s.watchos.deployment_target = "2.0"

  s.source       = { :git => "https://github.com/vapor/debugging.git", :tag => '1.0.0-beta.1' }
  
  s.source_files  = ["Sources/**/*.swift" ]
  
  
  s.requires_arc = true
  # s.framework = "CFNetwork"
  s.module_name = "Debugging"

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '3.1' }
end
