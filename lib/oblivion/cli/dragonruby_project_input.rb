# frozen_string_literal: true

module Oblivion
  class CLI < Thor
    class DragonrubyProjectInput
      attr_reader :data

      REQUIRE_STATEMENT = /^require\s+["'](?<filename>[^'"]+)['"].*\n/.freeze

      def initialize(path)
        @path = path
        @data = read_project_file 'app/main.rb'

        @data.gsub!(REQUIRE_STATEMENT) do |m|
          match = REQUIRE_STATEMENT.match(m)

          read_project_file match[:filename]
        end
      end

      private

      def read_project_file(relative_path)
        result = nil
        File.open("#{@path}/#{relative_path}") do |f|
          result = f.read
        end
        result
      end
    end
  end
end
