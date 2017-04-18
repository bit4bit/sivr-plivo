# -*- coding: utf-8 -*-
Gem::Specification.new do |s|
  s.name = "SIVRPlivo"
  s.version = "1.0.0"
  s.date = "2017-04-17"
  s.author = "Bit4bit"
  s.homepage = "https://github.com/sivr-plivo"
  s.email = "bit4bit@riseup.net"
  s.summary = "SingleIVR for Plivo"
  s.description = "This let write IVRs for Plivo easy how writing Ruby programs"
  s.files = [
    "lib/sivr_plivo.rb",
    ]
  s.has_rdoc = true
  s.require_paths = ["lib"]
  
  s.add_runtime_dependency('activesupport', '> 0.0')
  s.add_runtime_dependency('grape', '> 0.0')
end   
