# frozen_string_literal: true

require 'securerandom'

module Oblivion
  class Renamer
    LETTERS = ('a'..'z').to_a.freeze

    attr_reader :generated_names

    def initialize
      @new_names = {}
      @local_new_names = {}
      @generated_names = Set.new
    end

    def was_renamed?(name, local: false)
      names(local).key? name
    end

    def rename(name, local: false)
      new_name = nil
      loop do
        new_name = generate_new_name(name)
        break unless @generated_names.include? new_name
      end
      names(local)[name] = new_name
      @generated_names << new_name
    end

    def new_name_of(original_name)
      @local_new_names[original_name] || @new_names[original_name]
    end

    def clear_local
      @local_new_names.clear
    end

    private

    def names(local)
      local ? @local_new_names : @new_names
    end
  end

  class Renamer
    class Random < Renamer
      private

      def generate_new_name(_original_name)
        LETTERS.sample + SecureRandom.alphanumeric(10)
      end
    end
  end
end
