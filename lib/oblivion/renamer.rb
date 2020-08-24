# frozen_string_literal: true

require 'securerandom'

module Oblivion
  class Renamer
    LETTERS = ('a'..'z').to_a.freeze

    def initialize
      @new_names = {}
      @local_new_names = {}
    end

    def was_renamed?(name)
      @new_names.key?(name) || @local_new_names.key?(name)
    end

    def rename(name, local: false)
      target = local ? @local_new_names : @new_names
      target[name] = generate_new_name(name)
    end

    def new_name_of(original_name)
      @local_new_names[original_name] || @new_names[original_name]
    end

    def clear_local
      @local_new_names.clear
    end
  end

  class Renamer
    class Random < Renamer
      def initialize
        super
        @used_names = Set.new
      end

      def rename(name, local: false)
        @used_names << super
      end

      private

      def generate_new_name(_original_name)
        loop do
          new_name = LETTERS.sample + SecureRandom.alphanumeric(10)
          return new_name unless @used_names.include? new_name
        end
      end
    end
  end
end
