# frozen_string_literal: true

module Oblivion
  class Renamer
    attr_reader :renamed_methods

    def initialize
      @renamed_methods = Set.new
    end

    def rename(name)
      @renamed_methods << name
    end
  end
end
