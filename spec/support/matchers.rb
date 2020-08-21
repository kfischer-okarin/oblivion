# frozen_string_literal: true

RSpec::Matchers.define_negated_matcher :an_object_not_eq_to, :an_object_eq_to

RSpec::Matchers.define :a_node do |type, *children|
  match do |actual|
    return false unless values_match?(type, actual.type)

    children.each.with_index do |c, i|
      return false unless values_match?(c, actual.children[i])
    end

    true
  end
end

module CustomMatchers
  class AMethodDefinition
    include RSpec::Matchers::Composable

    def initialize(name)
      @name = name
      @body_matcher = nil
    end

    def matches?(value)
      result = value.type == :def && values_match?(@name, value.children[0])
      result &&= values_match?(@body_matcher, value.children[2]) if @body_matcher
      result
    end

    def with_body(matcher)
      @body_matcher = matcher
      self
    end

    def inspect
      result = "a definition of method #{description_of(@name)}"
      result += " with body #{description_of(@body_matcher)}"
      result
    end
  end

  def a_method_definition(name)
    AMethodDefinition.new(name)
  end
end

RSpec.configure do |_config|
  include CustomMatchers
end
