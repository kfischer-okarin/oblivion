# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe Oblivion::RewriteMethodContainer do
  subject(:result) { described_class.process(Unparser.parse(source), TestRenamer) }

  class TestRenamer < Oblivion::Renamer
    class << self
      attr_accessor :generated_count

      def reset
        @generated_count = 0
      end
    end

    def generate_new_name(original_name)
      self.class.generated_count += 1
      :"r_#{original_name}_#{self.class.generated_count}"
    end
  end

  before do
    TestRenamer.reset
  end

  describe TestRenamer do
    let(:renamer) { described_class.new }

    include_examples 'Renamer'
  end

  shared_examples 'it will produce equivalent of' do |expected_body|
    it { is_expected.to eq Unparser.parse(expected_body) }
  end

  shared_examples 'it will not change' do |source|
    let(:source) { source }

    include_examples 'it will produce equivalent of', source
  end

  describe 'Method names' do
    describe 'public and protected methods are unchanged' do
      include_examples 'it will not change', <<~RUBY
        class SomeClass
          def public_method; end

          protected
          def protected_method; end
        end
      RUBY
    end

    describe 'public and protected attribute accessors are unchanged' do
      include_examples 'it will not change', <<~RUBY
        class SomeClass
          attr_reader :public_attr_a
          attr_writer :public_attr_a
          attr_accessor :public_attr_b

          protected
          attr_reader :protected_attr_a
          attr_writer :protected_attr_a
          attr_accessor :protected_attr_b
        end
      RUBY
    end

    describe 'private initialize methods are unchanged' do
      include_examples 'it will not change', <<~RUBY
        class SomeClass
          private
          def initialize; end
        end
      RUBY
    end

    describe 'public methods after private methods will not change' do
      let(:source) {
        <<~RUBY
          class SomeClass
            private
            def method; end
            public
            def public_method; end
          end
        RUBY
      }

      include_examples 'it will produce equivalent of', <<~RUBY
        class SomeClass
          private
          def r_method_1; end
          public
          def public_method; end
        end
      RUBY
    end

    describe 'private methods will be renamed' do
      let(:source) {
        <<~RUBY
          class SomeClass
            private
            def method; end
          end
        RUBY
      }

      include_examples 'it will produce equivalent of', <<~RUBY
        class SomeClass
          private
          def r_method_1; end
        end
      RUBY
    end

    describe 'private attribute accessors will be renamed' do
      let(:source) {
        <<~RUBY
          class SomeClass
            private
            attr_reader :attr_a
            attr_writer :attr_b
            attr_accessor :attr_c
          end
        RUBY
      }

      include_examples 'it will produce equivalent of', <<~RUBY
        class SomeClass
          private
            attr_reader :r_attr_a_1
            attr_writer :r_attr_b_2
            attr_accessor :r_attr_c_3
        end
      RUBY
    end

    describe 'public methods after inline classes with private methods will not change' do
      let(:source) {
        <<~RUBY
          class SomeClass
            class Inline
              private
              def method; end
            end

            def public_method; end
          end
        RUBY
      }

      include_examples 'it will produce equivalent of', <<~RUBY
        class SomeClass
          class Inline
            private
            def r_method_1; end
          end

          def public_method; end
        end
      RUBY
    end

    describe 'public methods after class method blocks with private methods will not change' do
      let(:source) {
        <<~RUBY
          class SomeClass
            class << self
              private
              def method; end
            end

            def public_method; end
          end
        RUBY
      }

      include_examples 'it will produce equivalent of', <<~RUBY
        class SomeClass
          class << self
            private
            def r_method_1; end
          end

          def public_method; end
        end
      RUBY
    end

    describe 'public Struct methods after private methods will not change' do
      let(:source) {
        <<~RUBY
          class SomeClass
            private
            def private; end

            InternalStructure = Struct.new(:attr) do
              def some_method; end
            end
          end
        RUBY
      }

      include_examples 'it will produce equivalent of', <<~RUBY
        class SomeClass
          private
          def r_private_1; end
          InternalStructure = Struct.new(:attr) do
            def some_method; end
          end
        end
      RUBY
    end
  end

  describe 'Method bodies: with renamed private methods' do
    let(:source) {
      <<~RUBY
        class SomeClass
          def public_method
            method
            self.method
            local_var = method
            @ivar = method
            method.other_method
          end

          def other_public_method
            some_array[2] = method
            some_array.each do |el|
              method
            end
            result = (result | method)
          end

          private

          def method; end
        end
      RUBY
    }

    include_examples 'it will produce equivalent of', <<~RUBY
      class SomeClass
        def public_method
          r_method_1
          self.r_method_1
          r_local_var_2 = r_method_1
          @ivar = r_method_1
          r_method_1.other_method
        end

        def other_public_method
          some_array[2] = r_method_1
          some_array.each do |r_el_3|
            r_method_1
          end
          r_result_4 = (r_result_4 | r_method_1)
        end

        private

        def r_method_1; end
      end
    RUBY
  end

  describe 'Method bodies: renames are independent per class/module' do
    let(:source) {
      <<~RUBY
        class SomeClass
          def public_method; end

          private

          def method; end
        end

        class OtherClass
          def method; end
        end
      RUBY
    }

    include_examples 'it will produce equivalent of', <<~RUBY
      class SomeClass
        def public_method; end

        private

        def r_method_1; end
      end

      class OtherClass
        def method; end
      end
    RUBY
  end

  describe 'Method bodies: instance variable with private attribute accessors' do
    let(:source) {
      <<~RUBY
        class SomeClass
          def public_method
            @ivar = 4
            @ivar + @ivar
          end

          private

          attr_reader :ivar
        end
      RUBY
    }

    include_examples 'it will produce equivalent of', <<~RUBY
      class SomeClass
        def public_method
          @r_ivar_1 = 4
          @r_ivar_1 + @r_ivar_1
        end

        private

        attr_reader :r_ivar_1
      end
    RUBY
  end

  describe 'Method bodies: method arguments of private methods will be renamed' do
    let(:source) {
      <<~RUBY
        class SomeClass
          private

          def private_method(value1, value2)
            value1 + value2
          end
        end
      RUBY
    }

    include_examples 'it will produce equivalent of', <<~RUBY
      class SomeClass
        private

        def r_private_method_1(r_value1_2, r_value2_3)
          r_value1_2 + r_value2_3
        end
      end
    RUBY
  end

  describe 'Method bodies: local variables of private methods will be renamed' do
    let(:source) {
      <<~RUBY
        class SomeClass
          private

          def private_method
            my_local_var = 4
            my_local_var += my_local_var
          end
        end
      RUBY
    }

    include_examples 'it will produce equivalent of', <<~RUBY
      class SomeClass
        private

        def r_private_method_1
          r_my_local_var_2 = 4
          r_my_local_var_2 += r_my_local_var_2
        end
      end
    RUBY
  end

  describe 'Method bodies: method arguments of private methods will be renamed independently for each method' do
    let(:source) {
      <<~RUBY
        class SomeClass
          private

          def private_method(value)
            value + 2
          end

          def other_private_method(other_arg)
            value = 5
            other_arg + value
          end
        end
      RUBY
    }

    include_examples 'it will produce equivalent of', <<~RUBY
      class SomeClass
        private

        def r_private_method_1(r_value_3)
          r_value_3 + 2
        end

        def r_other_private_method_2(r_other_arg_4)
          r_value_5 = 5
          r_other_arg_4 + r_value_5
        end
      end
    RUBY
  end

  describe(
    'Method bodies: references to public arguments will not be changed ' \
    'even if there is a private method with the same name'
  ) do
    let(:source) {
      <<~RUBY
        class SomeClass
          def public_method(something)
            @something = something
          end

          private

          attr_reader :something
        end
      RUBY
    }

    include_examples 'it will produce equivalent of', <<~RUBY
      class SomeClass
        def public_method(something)
          @r_something_1 = something
        end

        private

        attr_reader :r_something_1
      end
    RUBY
  end

  describe 'Method bodies: local variables and private methods with same name will be named differently' do
    let(:source) {
      <<~RUBY
        class SomeClass
          def method
            calculated_value = calculated_value(arg)
          end

          private

          def calculated_value(value)
          end
        end
      RUBY
    }

    include_examples 'it will produce equivalent of', <<~RUBY
      class SomeClass
        def method
          r_calculated_value_2 = r_calculated_value_1(arg)
        end

        private

        def r_calculated_value_1(r_value_3)
        end
      end
    RUBY
  end

  describe 'Method bodies: inner struct renames are independent' do
    let(:source) {
      <<~RUBY
        class SomeClass
          def method; end

          def other_method
            method
          end

          InnerStruct = Struct.new(:value) do
            private

            def method; end
          end
        end
      RUBY
    }

    include_examples 'it will produce equivalent of', <<~RUBY
      class SomeClass
        def method; end

        def other_method
          method
        end

        InnerStruct = Struct.new(:value) do
          private

          def r_method_1; end
        end
      end
    RUBY
  end
end
