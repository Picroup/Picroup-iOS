# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'Picroup-iOS' do
  use_frameworks!

  pod 'Apollo', '~> 0.8'
  pod 'RxSwift', '~> 4.1'
  pod 'RxCocoa', '~> 4.1'
  pod 'RxDataSources', '~> 3.0'
  pod 'RxAlamofire', '~> 4.1'
  pod 'RxFeedback', '~> 1.0'
  pod 'RxGesture', '~> 1.2'
  pod 'RxViewController', '~> 0.3'
  pod 'RxRealm', '~> 0.7'
  pod 'Kingfisher', '~> 4.0'
  pod 'Material', '~> 2.14'
  pod 'YPImagePicker', '~> 3.0'
  
  post_install do |installer|
      # Your list of targets here.
      myTargets = ['YPImagePicker', 'PryntTrimmerView', 'SteviaLayout']
      
      installer.pods_project.targets.each do |target|
          if myTargets.include? target.name
              target.build_configurations.each do |config|
                  config.build_settings['SWIFT_VERSION'] = '4.1'
              end
          end
      end
  end
  
end
