# frozen_string_literal: true

require 'securerandom'

module Oblivion
  class Renamer
    LETTERS = ('a'..'z').to_a.freeze

    attr_reader :generated_names

    def initialize
      @new_names = {}
      @generated_names = Set.new
    end

    def create_local_renamer
      self.class.new.tap { |local_renamer|
        local_renamer.generated_names.merge(generated_names)
      }
    end

    def was_renamed?(name)
      @new_names.key? name
    end

    def rename(name)
      new_name = nil
      loop do
        new_name = generate_new_name(name)
        break unless @generated_names.include? new_name
      end
      @new_names[name] = new_name
      @generated_names << new_name
    end

    def new_name_of(original_name)
      @new_names[original_name]
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
