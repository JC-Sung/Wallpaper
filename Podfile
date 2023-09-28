# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Wallpaper' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Wallpaper

  pod 'Kingfisher', '~> 7.9.1'
  pod 'Alamofire'
  pod 'HandyJSON'
  pod 'SwiftyJSON'
  pod 'SwiftyUserDefaults'
  pod 'Lantern'
  pod 'ParallaxHeader', '~> 3.0.0'
  pod 'IQKeyboardManagerSwift'
  pod 'JXSegmentedView'
  pod 'SnapKit'
  pod 'CRRefresh'
  pod 'ETNavBarTransparent'
  pod 'SPIndicator'

end

post_install do |pi|
    pi.pods_project.targets.each do |t|
        t.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
        end
    end
end

