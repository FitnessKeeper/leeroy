# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'leeroy/version'

Gem::Specification.new do |spec|
  spec.name          = "leeroy"
  spec.version       = Leeroy::VERSION
  spec.authors       = ["Steve Huff"]
  spec.email         = ["steve.huff@runkeeper.com"]
  spec.summary       = %q{Automate tasks with Jenkins}
  spec.description   = %q{Leeroy is a framework and CLI app that captures common features required at various points in a CI pipeline.  It is designed to be invoked interactively or from Jenkins scripts.}
  spec.homepage      = "https://github.com/FitnessKeeper/leeroy"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "aruba", "~> 0.11.1"
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.3"
  spec.add_development_dependency "pry", "~> 0.10"
  spec.add_development_dependency "pry-awesome_print", "~> 9.6"

  spec.add_runtime_dependency "awesome_print", "~> 1.6"
  spec.add_runtime_dependency "aws-sdk", "~> 2"
  spec.add_runtime_dependency "dotenv", "~> 2.1"
  spec.add_runtime_dependency "fire_poll", "~> 1.2"
  spec.add_runtime_dependency "gli", "~> 2.13"
  spec.add_runtime_dependency "hashie", "~> 3.4"
  spec.add_runtime_dependency "yell", "~> 2.0"
end
