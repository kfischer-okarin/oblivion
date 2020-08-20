require_relative '../spec_helper'

RSpec.describe RubyUglifier::Uglifier do
  subject(:result) { described_class.new.process(Unparser.parse(source)) }

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

    describe 'unchanged' do
      describe 'public methods' do
        let(:class_body) {
          <<~RUBY
            def public_method; end
          RUBY
        }
        let(:expected_body) { a_method_definition(:public_method) }

        include_examples 'expected class body'
      end

      describe 'protected methods' do
        let(:class_body) {
          <<~RUBY
            protected
            def protected_method; end
          RUBY
        }
        let(:expected_body) { a_method_definition(:protected_method) }

        include_examples 'expected class body'
      end

      describe 'public methods after private methods' do
        let(:class_body) {
          <<~RUBY
            private
            def method; end
            public
            def public_method; end
          RUBY
        }
        let(:expected_body) { a_method_definition(:public_method) }

        include_examples 'expected class body'
      end

      describe 'methods after inline classes with private methods' do
        let(:class_body) {
          <<~RUBY
            class Inline
              private
              def method; end
            end

            def public_method; end
          RUBY
        }
        let(:expected_body) { a_method_definition(:public_method) }

        include_examples 'expected class body'
      end

      describe 'methods after class method blocks with private methods' do
        let(:class_body) {
          <<~RUBY
            class << self
              private
              def method; end
            end

            def public_method; end
          RUBY
        }
        let(:expected_body) { a_method_definition(:public_method) }

        include_examples 'expected class body'
      end

      describe 'private initialize method' do
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

    describe 'changed' do
      describe 'private methods' do
        let(:class_body) {
          <<~RUBY
            private
            def method; end
          RUBY
        }
        let(:expected_body) { a_method_definition(an_object_not_eq_to(:method)) }

        include_examples 'expected class body'
      end

      # TODO: Uglify instance_variables
      # shared_examples 'method definer' do |method_definer|
      #   describe "private #{method_definer}" do
      #     let(:class_body) {
      #       <<~RUBY
      #         private
      #         #{method_definer} :method, :method2
      #       RUBY
      #     }
      #     let(:expected_body) {
      #       a_node(:send, nil, method_definer, an_object_not_eq_to(s(:sym, :method)), an_object_not_eq_to(s(:sym, :method2)))
      #     }

      #     include_examples 'expected class body'
      #   end
      # end

      # include_examples 'method definer', :attr_reader
      # include_examples 'method definer', :attr_writer
      # include_examples 'method definer', :attr_accessor

      describe 'private methods in inline classes' do
        let(:class_body) {
          <<~RUBY
            class Inline
              private
              def method; end
            end
          RUBY
        }

        let(:expected_body) {
          a_node(:class,
                  s(:const, nil, :Inline), nil,
                  including(a_method_definition(an_object_not_eq_to(:method))))
        }

        include_examples 'expected class body'
      end

      describe 'private methods in class method blocks' do
        let(:class_body) {
          <<~RUBY
            class << self
              private
              def method; end
            end
          RUBY
        }

        let(:expected_body) {
          a_node(:sclass, s(:self),
                  including(a_method_definition(an_object_not_eq_to(:method))))
        }

        include_examples 'expected class body'
      end
    end
  end

  describe 'Usages of renamed private methods' do
    let(:source) {
      <<~RUBY
        class SomeClass
          def public_method
            #{method_body}
          end

          private

          def method; end
        end
      RUBY
    }

    shared_examples 'expected method body' do
      it { is_expected.to include(a_method_definition(:public_method).with_body(expected_body)) }
    end

    let(:new_method_name) {
      renamed_method = result.self_and_descendants.select { |n| n.type == :def }.last
      renamed_method.children[0]
    }

    let(:method_call_with_new_name) {
      s(:send, nil, new_method_name)
    }

    context 'called without receiver' do
      let(:method_body) { 'method' }
      let(:expected_body) { method_call_with_new_name }

      include_examples 'expected method body'
    end

    context 'called with self receiver' do
      let(:method_body) { 'self.method' }
      let(:expected_body) { s(:send, s(:self), new_method_name) }

      include_examples 'expected method body'
    end

    context 'on the right hand of a local variable assignment' do
      let(:method_body) { 'local_var = method' }
      let(:expected_body) { s(:lvasgn, :local_var, method_call_with_new_name) }

      include_examples 'expected method body'
    end

    context 'on the right hand of an instance variable assignment' do
      let(:method_body) { '@ivar = method' }
      let(:expected_body) { s(:ivasgn, :@ivar, method_call_with_new_name) }

      include_examples 'expected method body'
    end

    context 'on the right hand of an assignment to an array/hash index' do
      let(:method_body) { '@ivar[1] = method' }
      let(:expected_body) { s(:indexasgn, s(:ivar, :@ivar), s(:int, 1), method_call_with_new_name) }

      include_examples 'expected method body'
    end

    context 'as receiver of a method' do
      let(:method_body) { 'method.other_method' }
      let(:expected_body) { s(:send, method_call_with_new_name, :other_method) }

      include_examples 'expected method body'
    end

    context 'inside a block' do
      let(:method_body) {
        <<~RUBY
          (1..10).each do |i|
            method
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

    context 'inside a complex expression' do
      let(:method_body) {
        <<~RUBY
          result = (result | method)
        RUBY
      }
      let(:expected_body) {
        s(:lvasgn, :result, s(:begin, s(:send, s(:lvar, :result), :|, method_call_with_new_name)))
      }

      include_examples 'expected method body'
    end
  end
end
