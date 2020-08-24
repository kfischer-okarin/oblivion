# frozen_string_literal: true

require 'ast'
require 'unparser'

require_relative 'support/coverage'
require_relative 'support/renamer_examples'
require_relative '../lib/oblivion'

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
