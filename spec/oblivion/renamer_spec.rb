# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe Oblivion::Renamer do
  let(:renamer) { described_class.new }

  shared_examples 'Renamer' do
    describe 'Renamer common features' do
      let(:old_name) { 'old_name' }

      describe '#rename' do
        it 'marks the name as renamed' do
          expect { renamer.rename(old_name) }.to(change { renamer.was_renamed?(old_name) }.from(false).to(true))
        end

        it 'creates a new name' do
          renamer.rename(old_name)
          expect(renamer.new_name_of(old_name)).not_to eq old_name
        end

        it 'creates a different name for each method' do
          another_name = 'another_name'
          renamer.rename(old_name)
          renamer.rename(another_name)
          expect(renamer.new_name_of(old_name)).not_to eq renamer.new_name_of(another_name)
        end
      end
    end
  end

  describe Oblivion::Renamer::Random do
    describe '#rename' do
      subject(:rename) { renamer.rename(old_name) }
      let(:old_name) { :method_name }

      include_examples 'Renamer'

      it 'creates a 11 character random name' do
        rename

        expect(renamer.new_name_of(old_name)).to be_a(String).and have_attributes(size: 11)
      end
    end
  end
end
