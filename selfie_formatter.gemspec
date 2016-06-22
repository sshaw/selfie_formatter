# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'selfie/version'

Gem::Specification.new do |spec|
  spec.name          = "selfie_formatter"
  spec.version       = Selfie::VERSION
  spec.authors       = ["Skye Shaw"]
  spec.email         = ["skye.shaw@gmail.com"]

  spec.summary       = "RSpec Formatter that takes photos of you while your tests run and uses them to track progress and format the results."
  spec.description =<<-DESC
    An RSpec Formatter for the new generation for programmers.
    Selfie Formatter takes photos of you while your tests run and uses them to track progress and format the results.
    Currently only works on OS X with iTerm2 >= 3.0.
  DESC

  spec.homepage      = "https://github.com/sshaw/selfie_formatter"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rspec", "~> 3.0"
  spec.add_dependency "mini_magick", "~> 4.0"
  spec.add_dependency "tty-cursor", "~> 0.3"
  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
end
