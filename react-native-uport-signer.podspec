Pod::Spec.new do |s|
  s.name         = "react-native-uport-signer"
  s.author       = { "Aldi Gjoka" => "aldi.gjoka@consensys.net" }

  s.version      = "0.1.0"
  s.summary      = "Native modules for signing ethereum transactions and uport JWTs"
  s.license      = "Apache"

  s.homepage     = "https://github.com/uport-project/react-native-uport-signer"
  s.source       = { git: "https://github.com/uport-project/react-native-uport-signer.git", :tag => "#{s.version}" }

  s.requires_arc = true
  s.source_files  = "./*"
  s.platform     = :ios, "10.0"

  s.dependency "UPTEthereumSigner"
end