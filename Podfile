source 'https://github.com/CocoaPods/Specs.git'
platform :osx ,'10.10'

target :QYXcodePlugIn do
  pod "PromiseKit" ,'~> 1.6.0'
  pod "XcodeEditor"
  pod 'CCNPreferencesWindowController'
end


post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == "XcodeEditor"
           target.build_configurations.each do |config|
             config.build_settings['GCC_NO_COMMON_BLOCKS'] = 'NO'
           end
        end
    end
end
