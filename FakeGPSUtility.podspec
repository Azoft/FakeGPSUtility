Pod::Spec.new do |s|

  s.name         = "FakeGPSUtility"
  s.version      = "1.0.0"
  s.summary      = "Utility for debugging locations"
  s.homepage     = "http://www.azoft.com/"
  s.license      = 'MIT'
  s.ios.deployment_target = '6.0'
  s.public_header_files = '*.h'
  s.source       = { :git => "https://github.com/Azoft/FakeGPSUtility", :tag => "1.0.0" }
  s.source_files  = 'FakeGPSUtility/FakeGPSUtility/**/*.{h,m}'
  s.resources = 'FakeGPSUtility/FakeGPSUtility/**/*.{xib}'
  s.frameworks = 'MapKit', 'CoreLocation'
  s.requires_arc = true

end
