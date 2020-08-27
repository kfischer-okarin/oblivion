# frozen_string_literal: true

module Oblivion
  class CLI < Thor
    # Reads a single Ruby file
    class SingleFileInput
      attr_reader :data

      def initialize(filename)
        File.open(filename) do |file|
          @data = file.read
        end
      end
    end
  end
end
