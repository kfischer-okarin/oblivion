require_relative '../spec_helper'

RSpec.describe RubyUglifier::Uglifier do
  subject(:result) { described_class.new.process(Unparser.parse(source)) }

  RSpec::Matchers.define_negated_matcher :an_object_not_eq_to, :an_object_eq_to

  class AMethodDefinition
    include RSpec::Matchers::Composable

    def initialize(name)
      @name = name
      @body_matcher = nil
    end

    def matches?(value)
      result = value.type == :def && values_match?(@name, value.children[0])
      result = result && values_match?(@body_matcher, value.children[2]) if @body_matcher
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

  describe 'Method names' do
    let(:source) {
      <<~RUBY
        class SomeClass
          #{class_body}
        end
      RUBY
    }

    shared_examples 'expected class body' do
      it { is_expected.to include(expected_body) }
    end

    describe 'public method names are unchanged' do
      let(:class_body) {
        <<~RUBY
          def public_method; end
        RUBY
      }
      let(:expected_body) { a_method_definition(:public_method) }

      include_examples 'expected class body'
    end

    describe 'public method names after protected/private methods are unchanged' do
      let(:class_body) {
        <<~RUBY
          private
          def private_method; end
          public
          def public_method; end
        RUBY
      }
      let(:expected_body) { a_method_definition(:public_method) }

      include_examples 'expected class body'
    end

    describe 'protected method names are changed' do
      let(:class_body) {
        <<~RUBY
          protected
          def protected_method; end
        RUBY
      }
      let(:expected_body) { a_method_definition(an_object_not_eq_to(:protected_method)) }

      include_examples 'expected class body'
    end

    describe 'private method names are changed' do
      let(:class_body) {
        <<~RUBY
          private
          def private_method; end
        RUBY
      }
      let(:expected_body) { a_method_definition(an_object_not_eq_to(:private_method)) }

      include_examples 'expected class body'
    end

    describe 'private initialize method is not changed' do
      let(:class_body) {
        <<~RUBY
          private
          def initialize; end
        RUBY
      }
      let(:expected_body) { a_method_definition(:initialize) }

      include_examples 'expected class body'
    end
  end

  describe 'Usages of renamed methods' do
    let(:source) {
      <<~RUBY
        class SomeClass
          def public_method
            #{method_body}
          end

          private

          def private_method; end
        end
      RUBY
    }

    shared_examples 'expected method body' do
      it { is_expected.to include(a_method_definition(:public_method).with_body(expected_body)) }
    end

    let(:new_method_name) {
      private_method_definition = result.self_and_descendants.select { |n| n.type == :def }.last
      private_method_definition.children[0]
    }

    let(:method_call_with_new_name) {
      s(:send, nil, new_method_name)
    }

    context 'called without receiver' do
      let(:method_body) { 'private_method' }
      let(:expected_body) { method_call_with_new_name }

      include_examples 'expected method body'
    end

    context 'called with self receiver' do
      let(:method_body) { 'self.private_method' }
      let(:expected_body) { s(:send, s(:self), new_method_name) }

      include_examples 'expected method body'
    end

    context 'on the right hand of a local variable assignment' do
      let(:method_body) { 'local_var = private_method' }
      let(:expected_body) { s(:lvasgn, :local_var, method_call_with_new_name) }

      include_examples 'expected method body'
    end

    context 'on the right hand of an instance variable assignment' do
      let(:method_body) { '@ivar = private_method' }
      let(:expected_body) { s(:ivasgn, :@ivar, method_call_with_new_name) }

      include_examples 'expected method body'
    end

    context 'on the right hand of an assignment to an array/hash index' do
      let(:method_body) { '@ivar[1] = private_method' }
      let(:expected_body) { s(:indexasgn, s(:ivar, :@ivar), s(:int, 1), method_call_with_new_name) }

      include_examples 'expected method body'
    end

    context 'as receiver of a method' do
      let(:method_body) { 'private_method.method' }
      let(:expected_body) { s(:send, method_call_with_new_name, :method) }

      include_examples 'expected method body'
    end

    context 'inside a block' do
      let(:method_body) {
        <<~RUBY
          (1..10).each do |i|
            private_method
          end
        RUBY
      }
      let(:expected_body) {
        s(:block,
          s(:send, s(:begin, s(:irange, s(:int, 1), s(:int, 10))), :each),
          s(:args, s(:procarg0, s(:arg, :i))),
          method_call_with_new_name
        )
      }

      include_examples 'expected method body'
    end
  end
end
