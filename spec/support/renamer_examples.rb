# frozen_string_literal: true

RSpec.shared_examples 'Renamer' do
  describe 'Renamer common features' do
    let(:old_name) { 'old_name' }

    shared_examples 'rename common' do
      it 'creates a new name' do
        rename(old_name)
        expect(renamer.new_name_of(old_name)).not_to eq old_name
      end

      it 'creates a different name for each method' do
        another_name = 'another_name'
        rename(old_name)
        rename(another_name)
        expect(renamer.new_name_of(old_name)).not_to eq renamer.new_name_of(another_name)
      end

      it 'creates a different name each time' do
        rename(old_name)
        first_generated = renamer.new_name_of(old_name)
        rename(old_name)
        expect(renamer.new_name_of(old_name)).not_to eq first_generated
      end
    end

    describe '#rename' do
      def rename(name)
        renamer.rename(name)
      end

      include_examples 'rename common'

      it 'marks the name as renamed globally' do
        expect { renamer.rename(old_name) }.to(change { renamer.was_renamed?(old_name) }.from(false).to(true))
      end

      it 'does not mark the name as renamed locally' do
        expect { renamer.rename(old_name) }.not_to(change { renamer.was_renamed?(old_name, local: true) })
      end
    end

    describe '#rename(local: true)' do
      def rename(name)
        renamer.rename(name, local: true)
      end

      include_examples 'rename common'

      it 'marks the name as renamed locally' do
        expect { renamer.rename(old_name, local: true) }.to(
          change { renamer.was_renamed?(old_name, local: true) }.from(false).to(true)
        )
      end

      it 'does not mark the name as renamed globally' do
        expect { renamer.rename(old_name, local: true) }.not_to(change { renamer.was_renamed?(old_name) })
      end
    end

    describe '#clear_local' do
      subject(:clear_local) { renamer.clear_local }

      it 'clears local names' do
        renamer.rename(old_name, local: true)
        expect { clear_local }.to(change { renamer.was_renamed?(old_name, local: true) }.from(true).to(false))
      end
    end
  end
end
