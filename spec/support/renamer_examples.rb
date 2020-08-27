# frozen_string_literal: true

RSpec.shared_examples 'Renamer' do
  describe 'Renamer common features' do
    let(:old_name) { 'old_name' }

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
  end
end
