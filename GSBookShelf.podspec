Pod::Spec.new do |s|
  s.name         = "GSBookShelf"
  s.version      = "1.0"
  s.summary      = "A short description of GSBookShelf."
  s.homepage     = "https://github.com/ultragtx/GSBookShelf"
  s.license      = 'BSD'
  s.author       = { "ultragtx" => "ultragtx@gmail.com" }
  s.source       = { :git => "https://github.com/GlennChiu/GC3DFlipTransitionStyleSegue.git" }
  s.platform     = :ios, '5.0'
  s.source_files = 'Classes', 'Classes/BookShelf/**/*.{h,m}'
  s.public_header_files = 'Classes/BookShelf/**/*.h'
  s.framework  = 'QuartzCore'
  s.requires_arc = true
end
