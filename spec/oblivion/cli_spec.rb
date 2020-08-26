# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe Oblivion::CLI do
  let(:input) { described_class.start(argv) }

  shared_examples 'used input class' do |input_class|
    let(:input) { double(input_class, data: :source) }
    let(:uglified_source) { 'class MyClass;end' }

    it "uses #{input_class} for reading the input file" do
      expect(input_class).to receive(:new).with(argv[1]).and_return input
      expect(Oblivion).to receive(:uglify).with(:source).and_return uglified_source

      expect { described_class.start(argv) }.to output("#{uglified_source}\n").to_stdout
    end
  end

  context 'ruby <filename>' do
    let(:argv) { ['ruby', 'input.rb'] }

    include_examples 'used input class', Oblivion::CLI::SingleFileInput
  end

  context 'dragonruby <path>' do
    let(:argv) { ['dragonruby', 'dragonruby/mygame'] }

    include_examples 'used input class', Oblivion::CLI::DragonrubyProjectInput
  end
end
