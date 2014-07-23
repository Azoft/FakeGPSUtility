Pod::Spec.new do |s|

  s.name         = "FakeGPSUtility"
  s.version      = "0.0.1"
  s.summary      = "Utility for debugging locations"

  s.description  = <<-DESC
                   A longer description of FakeGPSUtility in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC

  s.homepage     = "http://www.azoft.com/"
  s.license      = 'MIT'
  # s.platform     = :ios, '5.0'

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the location from where the source should be retrieved.
  #  Supports git, hg, bzr, svn and HTTP.
  #

  s.source       = { :git => "http://EXAMPLE/FakeGPSUtility.git", :tag => "0.0.1" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any h, m, mm, c & cpp files. For header
  #  files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #

  s.source_files  = 'FakeGPSUtility/**/*.{h,m}', 'Libraries/**/*.{h,m}'
  s.exclude_files = 'FakeGPSUtility/Images/**/*.png'

  s.resources = 'FakeGPSUtility/Images/**/*.png'

  s.frameworks = 'MapKit', 'CoreLocation'

  s.requires_arc = true

end
