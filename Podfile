# Uncomment this line to define a global platform for your project
platform :ios, '9.0'
use_frameworks!

target 'Authtest' do
    #pod 'Firebase/AdMob'
    #pod 'Firebase/Analytics'
    #pod 'Firebase/AppIndexing'
    pod 'Firebase/Auth'
    pod 'Firebase/Core'
    pod 'Firebase/Crash'
    pod 'Firebase/Database'
    #pod 'Firebase/DynamicLinks'
    #pod 'Firebase/Invites'
    pod 'Firebase/Messaging'
    #pod 'Firebase/RemoteConfig'
    pod 'Firebase/Storage'
    pod 'GoogleMaps'
    pod 'JSQMessagesViewController'
    #pod ‘RAMReel’
    pod 'NVActivityIndicatorView'
    pod 'OneSignal'
end
# should end here
# found: http://stackoverflow.com/questions/38446097/xcode-8-beta-3-use-legacy-swift-issue
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = ‘2.3’
    end
  end
end