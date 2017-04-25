Pod::Spec.new do |s|

  s.name         = "VaporBits"
  s.version      = "1.0.1"
  s.summary      = "A bite sized library for dealing with bytes. "

  s.description  = <<-DESC
                  A bite sized library for dealing with bytes. mirror from vapor/bits for CocoaPods
                   DESC

  s.homepage     = "https://github.com/vapor/bits"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.authors            = { "vapor" => "vapor@gmai.com" }

  s.ios.deployment_target = "8.0"
  s.tvos.deployment_target = "9.0"
  s.osx.deployment_target = "10.10"
  s.watchos.deployment_target = "2.0"

  s.source       = { :git => "https://github.com/vapor/bits.git", :tag => '1.0.0-beta.4' }
  
  s.source_files  = ["Sources/**/*.swift" ]
  
  
  s.requires_arc = true
  # s.framework = "CFNetwork"
  s.module_name = "Bits"

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '3.1' }
end
