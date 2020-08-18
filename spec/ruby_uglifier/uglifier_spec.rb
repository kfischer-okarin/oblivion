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

    let(:method_names) { method_nodes.map { |m| m.children[0] } }

    let(:method_bodies) {
      method_nodes.map { |m|
        body = m.children[2]
        if body.nil?
          []
        elsif body.type == :begin
          body.children
        else
          [body]
        end
      }
    }

    describe 'renames private or protected methods' do
      subject { method_names }

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

    describe 'use renamed protected/private method names' do
      subject { method_bodies }

      let(:source) {
        <<~RUBY
          class SomeClass
            def public_method
              protected_method
              self.protected_method

              local_var = private_method
              @ivar = private_method
              protected_method.method
              private_method.each do |block_arg|
                protected_method
              end
            end

            protected
            def protected_method
              private_method
              self.private_method
            end

            private
            def private_method; end
          end
        RUBY
      }

      let(:expected) {
        [
          [
            s(:send, nil, method_names[1]),
            s(:send, s(:self), method_names[1]),
            s(:lvasgn, :local_var, s(:send, nil, method_names[2])),
            s(:ivasgn, :@ivar, s(:send, nil, method_names[2])),
            s(:send, s(:send, nil, method_names[1]), :method),
            s(:block,
              s(:send, s(:send, nil, method_names[2]), :each),
              s(:args, s(:procarg0, s(:arg, :block_arg))),
              s(:send, nil, method_names[1])
            )
          ],
          [
            s(:send, nil, method_names[2]),
            s(:send, s(:self), method_names[2])
          ],
          []
        ]
      }

      it { is_expected.to match expected }
    end
  end
end
