# frozen_string_literal: true

require 'securerandom'

module Oblivion
  class Renamer
    LETTERS = ('a'..'z').to_a.freeze

    attr_reader :renamed_methods, :new_names

    def initialize
      @renamed_methods = Set.new
      @new_names = {}
      @used_names = Set.new
    end

    def rename(name)
      @renamed_methods << name
      @new_names[name] = generate_new_name(name)
      @used_names << @new_names[name]
    end

    def generate_new_name(_original_name)
      loop do
        new_name = LETTERS.sample + SecureRandom.alphanumeric(10)
        return new_name unless @used_names.include? new_name
      end
    end
  end
end
