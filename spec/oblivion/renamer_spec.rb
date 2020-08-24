# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe Oblivion::Renamer do
  let(:renamer) { described_class.new }

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
