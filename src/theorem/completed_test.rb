# frozen_string_literal: true

module Theorem
  module Control
    # error class
    class CompletedTest
      attr_reader :name, :error

      def initialize(name, error = nil)
        @name = name
        @error = error
      end

      def failed?
        !@error.nil?
      end
    end
  end
end
