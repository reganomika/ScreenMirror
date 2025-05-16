platform :ios, '17.0'

use_frameworks!
inhibit_all_warnings!

# Common
def common_pods
  pod 'Telegraph'
  pod 'GoogleWebRTC'
  pod 'Swifter'
end

target 'ScreenMirror' do
  common_pods
  pod 'CocoaUPnP'
  pod 'GCDWebServer'

end

target 'Broadcast' do
  common_pods
end

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'No'
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
               end
          end
   end
end

