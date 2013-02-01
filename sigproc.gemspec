# -*- encoding: utf-8 -*-

require File.expand_path('../lib/sigproc/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "sigproc"
  gem.version       = Sigproc::VERSION
  gem.summary       = %q{Perform primary signal processing functions and provide infrastructure for forming processing networks.}
  gem.description   = <<DESCRIPTION
Perform primary signal processing functions and provide infrastructure
for forming processing networks.
DESCRIPTION
  gem.license       = "MIT"
  gem.authors       = ["James Tunnell"]
  gem.email         = "jamestunnell@lavabit.com"
  gem.homepage      = "https://rubygems.org/gems/sigproc"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'wavefile'

  gem.add_development_dependency 'bundler', '~> 1.0'
  gem.add_development_dependency 'rake', '~> 0.8'
  gem.add_development_dependency 'rspec', '~> 2.4'
  gem.add_development_dependency 'yard', '~> 0.8'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'gnuplot'
end
