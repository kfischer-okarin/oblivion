# frozen_string_literal: true

require_relative 'lib/oblivion/version'

Gem::Specification.new do |spec|
  spec.name          = 'oblivion'
  spec.version       = Oblivion::VERSION
  spec.summary       = 'A Ruby code uglifier'
  spec.authors       = ['Kevin Fischer']
  spec.description   = spec.description
  spec.homepage      = 'https://github.com/kfischer-okarin/oblivion'
  spec.license       = 'MIT'

  spec.executables << 'oblivion'

  spec.required_ruby_version = '>= 2.4.0'

  spec.add_dependency             'parser',                '~> 2.7'
  spec.add_dependency             'strings-case',          '~> 0.3.0'
  spec.add_dependency             'thor',                  '~> 1.0'
  spec.add_dependency             'unparser',              '~> 0.4.7'

  spec.add_development_dependency 'codecov',               '~> 0.2.6'
  spec.add_development_dependency 'guard-rspec',           '~> 4.7'
  spec.add_development_dependency 'rspec',                 '~> 3.9'
  spec.add_development_dependency 'rspec_junit_formatter', '~> 0.4.1'
  spec.add_development_dependency 'simplecov',             '~> 0.19.0'

  spec.add_development_dependency 'reek',                  '~> 6.0'
  spec.add_development_dependency 'rubocop',               '~> 0.89.1'
  spec.add_development_dependency 'rubocop-rspec',         '~> 1.43'
end
