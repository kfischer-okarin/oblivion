# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe Oblivion::CLI do
  let(:input) { described_class.start(argv) }

  context 'ruby <filename>' do
    let(:argv) { ['ruby', 'input.rb'] }

    let(:input_class) { Oblivion::CLI::SingleFileInput }
    let(:uglified_source) { 'class MyClass;end' }
    let(:input) { double(input_class, data: :source) }

    it 'uses SingleFileInput' do
      expect(input_class).to receive(:new).with(argv[1]).and_return input
      expect(Oblivion).to receive(:uglify).with(:source).and_return uglified_source

      expect { described_class.start(argv) }.to output("#{uglified_source}\n").to_stdout
    end
  end
end
