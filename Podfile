# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'SnapSieve' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
pod 'FloatRatingView', '~> 2.0.0'
pod 'WCLShineButton'
pod 'SwiftyJSON', '~> 4.0'
pod 'AlamofireImage', '~> 3.3'
pod 'Alamofire', '~> 4.7'
pod 'Nuke', '7.0-beta2'
pod "Floaty", "~> 4.0.0"
pod 'Firebase/Performance'
pod 'Crashlytics', '~> 3.10.0'
pod 'SDWebImage', '~> 4.0'
pod 'ZAlertView'
pod 'CropViewController'
pod 'SVProgressHUD'
pod 'UICircularProgressRing'
pod 'Gallery'
pod 'Hero', '~> 1.0'
pod 'Firebase/Messaging'
pod 'Firebase/Core'
pod 'Firebase/Auth'
pod 'Firebase/Database'
pod 'Firebase/Storage'
pod 'GoogleSignIn'
pod 'FBSDKLoginKit'
pod 'SwiftKeychainWrapper', '~> 3.0'
  # Pods for SnapSieve
post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
end
end
