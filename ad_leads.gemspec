# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ad_leads/version'

Gem::Specification.new do |spec|
  spec.name          = "ad_leads"
  spec.version       = AdLeads::VERSION
  spec.authors       = ["Dinshaw"]
  spec.email         = ["dgobhai@constantcontact.com"]
  spec.summary       = %q{Ruby Wrapper for AdLeads API}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'oauth2'

  spec.add_dependency 'httpclient'
  spec.add_development_dependency 'rspec', '~> 2.14'
  spec.add_development_dependency 'bundler', "~> 1.5"
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'pry'
end
