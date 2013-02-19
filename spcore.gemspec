# -*- encoding: utf-8 -*-

require File.expand_path('../lib/spcore/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "spcore"
  gem.version       = SPCore::VERSION
  gem.summary       = %q{A library of signal processing methods and classes.}
  gem.description   = <<DESCRIPTION
Contains core signal processing methods and classes, including:
  * Resampling (discrete up, down and up/down, polynomial up, and hybrid up/down).
  * FFT transform (forward and inverse).
  * DFT transform (forward and inverse).
  * Windows (Blackman, Hamming, etc.).
  * Windowed sinc filter for lowpass and highpass.
  * Dual windowed sinc filter for bandpass and bandstop.
  * Interpolation (linear and polynomial).
  * Data plotting via gnuplot (must be installed to use).
  * Delay line.
  * Biquad filters.
  * Envelope detector.
  * Conversion from dB-linear and linear-dB.
  * Oscillator with selectable wave type (sine, square, triangle, sawtooth).
  * Signal abstraction class.

DESCRIPTION
  gem.license       = "MIT"
  gem.authors       = ["James Tunnell"]
  gem.email         = "jamestunnell@lavabit.com"
  gem.homepage      = "https://rubygems.org/gems/spcore"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'hashmake'
  gem.add_dependency 'gnuplot'

  gem.add_development_dependency 'bundler', '~> 1.0'
  gem.add_development_dependency 'rake', '~> 0.8'
  gem.add_development_dependency 'rspec', '~> 2.4'
  gem.add_development_dependency 'yard', '~> 0.8'
  gem.add_development_dependency 'pry'
end
