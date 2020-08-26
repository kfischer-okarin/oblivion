# frozen_string_literal: true

require 'tempfile'

require_relative '../../spec_helper'

RSpec.describe Oblivion::CLI::SingleFileInput do
  let(:input) { described_class.new(file.path) }

  let(:file) {
    Tempfile.new.tap { |f|
      f.write(file_content)
      f.rewind
    }
  }

  after do
    file.close
    file.unlink
  end

  let(:file_content) {
    <<~RUBY
      require 'set'

      class MyClass
        def my_method(my_arg)
        end
      end
    RUBY
  }

  it 'returns the file content' do
    expect(input.data).to eq file_content
  end
end
