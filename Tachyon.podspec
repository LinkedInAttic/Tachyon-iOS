Pod::Spec.new do |spec|
  spec.name = 'Tachyon'
  spec.version = '0.0.23'
  spec.requires_arc = true
  spec.platform = :ios, '10.0'
  spec.summary = 'Tachyon provides configurable UI components commonly used in calendar features and applications.'
  spec.source = { :git => 'https://github.com/linkedin/Tachyon-iOS.git', :tag => spec.version }
  spec.homepage = "https://github.com/linkedin/Tachyon-iOS"
  spec.license = '2-clause BSD'
  spec.source_files = 'Tachyon/**/*.{swift,h,m}'
  spec.authors = 'LinkedIn'
  spec.ios.frameworks = 'Foundation', 'UIKit'
end
