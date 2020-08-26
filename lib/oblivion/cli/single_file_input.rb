# frozen_string_literal: true

module Oblivion
  class CLI < Thor
    class SingleFileInput
      attr_reader :data

      def initialize(filename)
        File.open(filename) do |f|
          @data = f.read
        end
      end
    end
  end
end
