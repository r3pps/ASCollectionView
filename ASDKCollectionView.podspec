
Pod::Spec.new do |s|
  s.name             = 'ASDKCollectionView'
  s.version          = '3.0.1'
  s.summary          = 'A SwiftUI collection view with support for custom layouts, preloading, and more. '

  s.description      = <<-DESC
  A SwiftUI implementation of UICollectionView & UITableView. Here's some of its useful features:
    - supports preloading and onAppear/onDisappear.
    - supports cell selection, with automatic support for SwiftUI editing mode.
    - supports autosizing of cells.
    - supports the new UICollectionViewCompositionalLayout, and any other UICollectionViewLayout
    - supports removing separators for ASTableView.
                       DESC

  s.homepage         = 'https://github.com/r3pps/ASCollectionView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'r3pps' => '' }
  s.source           = { :git => 'https://github.com/r3pps/ASCollectionView.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.swift_versions = '5.3'
  s.source_files = 'Sources/ASCollectionView/**/*'
  s.dependency 'DifferenceKit', '~> 1.1'
  s.dependency 'Texture', '~> 3.1.0'
end
