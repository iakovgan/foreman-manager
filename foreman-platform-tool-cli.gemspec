# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'foreman/platform/tool/cli/version'

Gem::Specification.new do |spec|
  spec.name          = "foreman-platform-tool-cli"
  spec.version       = Foreman::Platform::Tool::Cli::VERSION
  spec.authors       = ["Nagarjuna Rachaneni"]
  spec.email         = ["nagarjuna.r@indecomm.net"]

  spec.summary       = %q{Command line interface to deploy platform in foreman using blueprint}
  spec.description   = %q{This gem provide commands to deploy/view/update/delete platform using Foreman APIs}
  spec.homepage      = "http://sysgit01.lab.services.ingenico.com/infra/foreman-platform-tool-cli/tree/master"
  spec.license       = "MIT"

  spec.files         = Dir["{bin,lib, config}/**/*"] + ["LICENSE.txt", "Rakefile", "README.md", "Gemfile", "foreman-platform-tool-cli.gemspec"]
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})

  # spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  # spec.bindir        = "exe"
  # spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_dependency "colorize","~> 0.7"
  spec.add_dependency "json","~> 1.5"
  # spec.add_dependency 'rest-client', '1.5'
end
