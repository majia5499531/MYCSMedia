
Pod::Spec.new do |s|
  s.name             = 'MYCSMedia'
  s.version          = '1.1.6'
  s.summary          = 'SZRM Media Module'


  s.description      = 'Media UI'

  s.homepage         = 'https://github.com/majia5499531@163.com/MYCSMedia'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'majia5499531@163.com' => '5307460+azbura@user.noreply.gitee.com' }
  s.source           = { :git => 'https://github.com/majia5499531/MYCSMedia.git', :tag => s.version.to_s }
  

  s.ios.deployment_target = '9.0'

  s.source_files = 'MYCSMedia/Classes/**/*'
  
  s.resource_bundles = {
     'CSAssets' => ['MYCSMedia/Assets/*']
   }
  
  s.dependency 'AFNetworking', '>= 4.0'
  s.dependency 'TXLiteAVSDK_Player', '~> 7.1.8775'
  s.dependency 'MMLayout', '>= 0.3.0'
  s.dependency 'Masonry', '>= 1.1.0'
  s.dependency 'SDWebImage', '>= 5.0'
  s.dependency 'FSTextView', '>= 1.8'
  s.dependency 'MJRefresh', '>= 3.6.1'
  s.dependency 'YYModel'
  s.static_framework = true
  
end
