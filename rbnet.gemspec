# frozen_string_literal: true

require_relative 'lib/rbnet/version'

Gem::Specification.new do |spec|
  spec.name          = 'rbnet'
  spec.version       = Rbnet::VERSION
  spec.authors       = ['nbr-hgwr']

  spec.summary       = 'Ruby tool to run test network'
  spec.description   = 'Ruby tool to run test network'
  spec.homepage      = 'https://github.com/nbr-hgwr/rbnet'
  spec.required_ruby_version = Gem::Requirement.new('>= 3.1.0')

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'ipaddr'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'thor'
end
