# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe Oblivion do
  describe '.uglify' do
    subject(:result) { described_class.uglify(source) }

    let(:source) {
      <<~RUBY
        class MyClass; end

        module MyModule; end
      RUBY
    }

    it 'parses the source uglifies it and produces resulting source code' do
      expect(Unparser).to receive(:parse).with(source).and_return :parsed_ast
      expect(Oblivion::Uglifier).to receive(:process).with(:parsed_ast).and_return :uglified_ast
      expect(Unparser).to receive(:unparse).with(:uglified_ast).and_return 'uglified_source'
      expect(result).to eq 'uglified_source'
    end

    it 'does not produce new lines' do
      expect(result).not_to include("\n")
    end
  end
end
