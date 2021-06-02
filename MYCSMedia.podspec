#
# Be sure to run `pod lib lint MYCSMedia.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MYCSMedia'
  s.version          = '1.0'
  s.summary          = 'MY CS Media Module'


  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/majia5499531@163.com/MYCSMedia'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'majia5499531@163.com' => '5307460+azbura@user.noreply.gitee.com' }
  s.source           = { :git => 'https://github.com/majia5499531/MYCSMedia.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'MYCSMedia/Classes/**/*'
  
   s.resource_bundles = {
     'CSAssets' => ['MYCSMedia/Assets/*']
   }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'AFNetworking', '>= 4.0'
  s.dependency 'TXLiteAVSDK_Player', '~> 7.1.8775'
  s.dependency 'MMLayout', '>= 0.3.0'
  s.dependency 'Masonry', '>= 1.1.0'
  s.dependency 'SDWebImage', '>= 5.0'
  s.dependency 'FSTextView', '>= 1.8'
  s.dependency 'MJRefresh', '>= 3.6.1'
  s.static_framework = true
end
