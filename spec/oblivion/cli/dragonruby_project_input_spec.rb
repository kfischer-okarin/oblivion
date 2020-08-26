# frozen_string_literal: true

require 'tmpdir'

require_relative '../../spec_helper'

RSpec.describe Oblivion::CLI::DragonrubyProjectInput do
  let(:input) { described_class.new(tempdir) }

  let(:tempdir) { Dir.mktmpdir }

  before do
    Dir.mkdir "#{tempdir}/app"
    File.open("#{tempdir}/app/main.rb", 'w') do |f|
      f.write(app_main_content)
    end
    File.open("#{tempdir}/app/player.rb", 'w') do |f|
      f.write(app_player_content)
    end
  end

  after do
    FileUtils.remove_entry tempdir
  end

  let(:app_main_content) {
    <<~RUBY
      require 'app/player.rb'

      class MyClass
        def my_method(my_arg)
        end
      end
    RUBY
  }

  let(:app_player_content) {
    <<~RUBY
      class Player
        def run
        end
      end
    RUBY
  }

  let(:expected_data) {
    <<~RUBY
      class Player
        def run
        end
      end

      class MyClass
        def my_method(my_arg)
        end
      end
    RUBY
  }

  it 'returns the combined content of the project' do
    expect(input.data).to eq expected_data
  end
end
