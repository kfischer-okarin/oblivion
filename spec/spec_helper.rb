require 'ast'
require 'unparser'

require_relative 'support/matchers.rb'
require_relative 'support/coverage.rb'
require_relative '../lib/oblivion.rb'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.disable_monkey_patching!
  config.order = :random
  Kernel.srand config.seed

  include AST::Sexp
end

module NodeExtensions
  def self_and_descendants
    Enumerator.new do |y|
      y << self

      children.each do |c|
        next unless c.is_a? AST::Node
        c.self_and_descendants.each do |cc|
          y << cc
        end
      end
    end
  end

  def include?(node)
    self_and_descendants.include? node
  end

  def any?(&block)
    self_and_descendants.any?(&block)
  end
end

AST::Node.include NodeExtensions
