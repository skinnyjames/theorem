# frozen_string_literal: true

module Theorem
  module Control
    # error class
    class CompletedTest
      attr_reader :test, :error

      def initialize(test, error = nil)
        @test = test
        @error = error
      end

      def full_name
        test.full_name
      end

      def name
        test.name
      end

      def failed?
        !@error.nil?
      end
    end
  end
end
