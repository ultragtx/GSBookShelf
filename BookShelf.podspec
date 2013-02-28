Pod::Spec.new do |s|
  s.name         = "BookShelf"
  s.version      = "1.0.0"
  s.summary      = "An iBooks-styled book shelf for iOS (Animation of drag & drop, insert, remove...)"
  s.homepage     = "https://github.com/ultragtx/GSBookShelf"
  s.license      = 'BSD'
  s.author       = { "ultragtx" => "ultragtx@gmail.com" }
  s.source       = { :git => "https://github.com/ultragtx/GSBookShelf.git" }
  s.platform     = :ios, '5.0'
  s.source_files = 'BookShelf/Classes/BookShelf/**/*.{h,m}'
  s.public_header_files = 'BookShelf/Classes/BookShelf/**/*.h'
  s.framework  = 'QuartzCore'
  s.requires_arc = true
end
