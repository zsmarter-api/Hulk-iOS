#
# Be sure to run `pod lib lint Hulk.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Hulk'
  s.version          = '2.6'
  s.summary          = 'Hulk 更方便、更可靠的推送'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = "Hulk 更方便、更可靠的推送"

  s.homepage         = 'https://codeup.aliyun.com/61bd4197ac40125af0f5fbe3/iOS/Hulk.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ztzh_xuj' => 'ztzh_xuj@ztzh.com' }
  s.source           = { :git => 'https://codeup.aliyun.com/61bd4197ac40125af0f5fbe3/iOS/Hulk.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  s.pod_target_xcconfig = { 'VALID_ARCHS' => 'x86_64 armv7 arm64' }
  s.static_framework = true

  s.source_files = 'Hulk/Classes/**/*'
  
  s.dependency 'MJExtension'
  s.dependency 'CocoaAsyncSocket'
  s.dependency 'YYCategories'
  s.dependency 'GMObjC'
end
