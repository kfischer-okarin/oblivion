require_relative '../spec_helper'

RSpec.describe RubyUglifier::Uglifier do
  RSpec::Matchers.define :not_eq_to do |expected|
    match do |value|
      value != expected
    end
  end

  describe '.uglify_ast' do
    subject(:result) { described_class.new.process(Unparser.parse(source)) }

    let(:class_nodes) {
      result.type == :class ? [result] : result.children.select { |n| n.type == :class }
    }

    let(:method_nodes) {
      class_nodes.flat_map { |c|
        body = c.children[2]
        if body.type == :def
          [body]
        else
          body.children.select { |n| n.type == :def }
        end
      }
    }

    describe 'method names' do
      subject(:method_names) { method_nodes.map { |m| m.children[0] } }

      describe 'renames private or protected methods' do
        let(:source) {
          <<~RUBY
            class SomeClass
              def public_method; end

              protected
              def protected_method; end

              private
              def private_method; end

              public
              def second_public_method; end
            end
          RUBY
        }

        let(:expected) {
          [
            eq_to(:public_method),
            not_eq_to(:protected_method),
            not_eq_to(:private_method),
            eq_to(:second_public_method)
          ]
        }

        it { is_expected.to match expected }
      end
    end
  end
end
