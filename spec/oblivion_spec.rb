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

    
  end
end
