# frozen_string_literal: true

RSpec.shared_examples 'Renamer' do
  describe 'Renamer common features' do
    let(:old_name) { 'old_name' }

    shared_examples 'rename common' do
      let(:generated_names) {
        Set.new(
          100.times.map {
            renamer.rename(old_name)
            renamer.new_name_of(old_name)
          }
        )
      }

      it 'creates a new name' do
        expect(generated_names).not_to include old_name
      end

      it 'creates a different name for each method' do
        another_name = 'another_name'
        rename(another_name)
        expect(generated_names).not_to include renamer.new_name_of(another_name)
      end

      it 'creates a different name each time' do
        # Because it's a set same names will not increase collection size
        expect(generated_names.size).to eq 100
      end
    end

    def generate_100_names
      100.times do
        renamer.rename(old_name)
      end
    end

    describe '#create_local_renamer' do
      subject(:created) { renamer.create_local_renamer }

      before do
        renamer.rename(old_name)
      end

      it 'knows all generated names so far' do
        expect(created.generated_names).to eql(renamer.generated_names)
      end

      it 'contains no renames' do
        expect(created.was_renamed?(old_name)).to be false
      end

      it 'is independent from the original renamer' do
        created.rename(old_name)
        renamer.rename(old_name)
        expect(created.generated_names).not_to eql(renamer.generated_names)
      end
    end

    describe '#generated_names' do
      subject { renamer.generated_names }

      it { is_expected.to be_a Set }
    end

    describe '#rename' do
      it 'creates a new name' do
        generate_100_names

        expect(renamer.generated_names).not_to include old_name
      end

      it 'creates a different name each time' do
        generate_100_names

        # Because it's a set same names will not increase collection size
        expect(renamer.generated_names.size).to eq 100
      end

      it 'marks the name as renamed globally' do
        expect { renamer.rename(old_name) }.to(change { renamer.was_renamed?(old_name) }.from(false).to(true))
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
