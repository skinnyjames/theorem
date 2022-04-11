# frozen_string_literal: true

module Theorem
  module Control
    # error class
    class CompletedTest
      attr_reader :test, :duration
      attr_accessor :error, :notary

      def initialize(test, error = nil, notary:, duration: nil)
        @test = test
        @error = error
        @notary = notary
        @duration = duration
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
