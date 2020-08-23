# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe Oblivion::Renamer::Random do
  let(:renamer) { described_class.new }

  describe '#rename' do
    subject(:rename) { renamer.rename(old_name) }
    let(:old_name) { :method_name }

    it 'creates a 11 character random name' do
      rename

      expect(renamer.new_name_of(old_name)).to be_a(String).and have_attributes(size: 11)
    end

    it 'marks the name as renamed' do
      expect { rename }.to(change { renamer.was_renamed?(old_name) }.from(false).to(true))
    end
  end
end
