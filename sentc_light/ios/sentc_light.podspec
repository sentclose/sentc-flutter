framework_name = 'SentcLight.xcframework'
local_zip_name = "#{framework_name}.zip"
`
cd Frameworks
rm -rf #{framework_name}
unzip #{local_zip_name}
cd -
`

Pod::Spec.new do |spec|
  spec.name          = 'sentc_light'
  spec.version       = '0.0.1'
  spec.license       = { :file => '../LICENSE' }
  spec.homepage      = 'https://sentc.com'
  spec.authors       = { 'Jörn Heinemann' => 'contact@sentclose.com' }
  spec.summary       = 'An end to end encryption sdk for every developer.'

  spec.source              = { :path => '.' }
  spec.source_files        = 'Classes/**/*'
  spec.public_header_files = 'Classes/**/*.h'
  spec.vendored_frameworks = "Frameworks/#{framework_name}"

  spec.ios.deployment_target = '11.0'
  spec.osx.deployment_target = '10.14'
end
