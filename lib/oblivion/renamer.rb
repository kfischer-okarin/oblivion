# frozen_string_literal: true

require 'securerandom'

module Oblivion
  # Generates new names and keeps track of them
  class Renamer
    LETTERS = ('a'..'z').to_a.freeze

    attr_reader :generated_names

    def initialize
      @new_names = {}
      @generated_names = Set.new
    end

    # Creates derived renamer for local variables/arguments which will not generate already generated names again
    def create_local_renamer
      self.class.new.tap { |local_renamer|
        local_renamer.generated_names.merge(generated_names)
      }
    end

    def was_renamed?(name)
      @new_names.key? name
    end

    def rename(original_name)
      new_name = generate_unused_name_for(original_name)
      @new_names[original_name] = new_name
      @generated_names << new_name
    end

    def new_name_of(original_name)
      @new_names[original_name]
    end

    private

    def generate_unused_name_for(original_name)
      loop do
        new_name = generate_name_for(original_name)
        return new_name unless @generated_names.include? new_name
      end
    end
  end

  class Renamer
    # Generates a random 11 character name
    class Random < Renamer
      private

      # :reek:UtilityFunction
      def generate_name_for(_original_name)
        LETTERS.sample + SecureRandom.alphanumeric(10)
      end
    end
  end
end
