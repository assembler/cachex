# -*- encoding: utf-8 -*-
require File.expand_path('../lib/cachex/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Milovan Zogovic"]
  gem.email         = ["milovan.zogovic@gmail.com"]
  gem.description   = %q{Automated tag based fragment caching}
  gem.summary       = %q{Automated tag based fragment caching}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "cachex"
  gem.require_paths = ["lib"]
  gem.version       = Cachex::VERSION
end
