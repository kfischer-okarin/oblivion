# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe Oblivion::Uglifier do
  subject(:result) { described_class.process(Unparser.parse(source), TestRenamer.new) }

  class TestRenamer < Oblivion::Renamer
    def generate_new_name(original_name)
      :"r_#{original_name}"
    end
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
          def r_method; end
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
          def r_method; end
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
            attr_reader :r_attr_a
            attr_writer :r_attr_b
            attr_accessor :r_attr_c
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
            def r_method; end
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
            def r_method; end
          end

          def public_method; end
        end
      RUBY
    end
  end

  describe 'Method bodies of renamed private methods' do
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
          r_method
          self.r_method
          local_var = r_method
          @ivar = r_method
          r_method.other_method
        end

        def other_public_method
          some_array[2] = r_method
          some_array.each do |el|
            r_method
          end
          result = (result | r_method)
        end

        private

        def r_method; end
      end
    RUBY
  end
end
