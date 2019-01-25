
Pod::Spec.new do |s|
  s.name         = "react-native-uport-signer"
  s.version      = "1.0.0"
  s.summary      = "Ethereum signer for react native"
  s.description  = <<-DESC
                  RNUportSigner
                   DESC
  s.homepage     = ""
  s.license      = "MIT"
  # s.license    = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author       = { "author" => "author@domain.cn" }
  s.platform     = :ios, "7.0"
  s.source       = { git: "https://github.com/author/RNUportSigner.git", tag: "s.version" }
  s.source_files  = "RNUportSigner/**/*.{h,m}"
  s.requires_arc = true

  s.dependency "React"
  s.dependency "UPTEThereumSigner"

end

  