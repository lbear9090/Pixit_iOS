# Uncomment the next line to define a global platform for your project
 platform :ios, '9.0'

target 'Pixit' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Pixit
pod 'CropViewController'
pod 'ChameleonFramework/Swift', :git => 'https://github.com/ViccAlexander/Chameleon.git'
pod 'AORangeSlider'
#pod 'OpenCV2'
pod 'OpenCV2-contrib'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if ['CropViewController', 'AORangeSlider'].include? target.name
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '4'
      end
    end
  end
end
