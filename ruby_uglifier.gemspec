# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'ruby_uglifier'
  spec.version       = '0.1.0'
  spec.summary       = 'A Ruby code uglifier'
  spec.authors       = ['Kevin Fischer']

  spec.required_ruby_version = '>= 2.0.0'

  spec.add_dependency             'parser',       '~> 2.7'
  spec.add_dependency             'unparser',     '~> 0.4.7'
  spec.add_dependency             'strings-case', '~> 0.3.0'

  spec.add_development_dependency 'rspec',        '~> 3.9'
  spec.add_development_dependency 'guard-rspec',  '~> 4.7'
end
