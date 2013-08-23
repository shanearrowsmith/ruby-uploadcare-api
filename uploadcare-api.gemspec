# -*- encoding: utf-8 -*-
require File.expand_path('../lib/uploadcare/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Vadim Rastyagaev"]
  gem.email         = ["abc@oktoberliner.ru"]
  gem.description   = "Ruby wrapper for Uploadcare service"
  gem.summary       = "Ruby wrapper for Uploadcare service"
  gem.homepage      = "https://uploadcare.com"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "uploadcare-api"
  gem.require_paths = ["lib"]
  gem.version       = Uploadcare::VERSION
  gem.add_runtime_dependency 'faraday'
  gem.add_runtime_dependency 'multipart-post'
  gem.add_runtime_dependency 'mime-types'

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'pry'
end
