# frozen_string_literal: true

RSpec.shared_examples 'Renamer' do
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

      it 'creates a different name each time' do
        renamer.rename(old_name)
        first_generated = renamer.new_name_of(old_name)
        renamer.rename(old_name)
        expect(renamer.new_name_of(old_name)).not_to eq first_generated
      end
    end
  end
end
