# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'travis-cron_tools/version'

Gem::Specification.new do |spec|
  spec.name          = "travis-cron_tools"
  spec.version       = Travis::CronTools::VERSION
  spec.authors       = ["Maarten Hoogendoorn"]
  spec.email         = ["maarten@moretea.nl"]

  spec.summary       = %q{Travis Cron tools}
  spec.description   = %q{Running expensive integration tests? With Travis Cron tools you can still have daily integration, but be selective about the tests you want to run}
  spec.homepage      = "https://github.com/microservices-demo/travis-cron_tools"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
