require 'simplecov'
SimpleCov.start

if ENV['CI']
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end
