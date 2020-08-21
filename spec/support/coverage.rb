require 'simplecov'
SimpleCov.start do
  add_filter 'spec'
end

if ENV['CI']
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end
