# frozen_string_literal: true

module Theorem
  module Control
    module Registry
      # beaker
      def registry
        @registry ||= []
      end

      def add_to_registry(klass)
        registry << klass
      end

      def on_completed_test(&block)
        @completed_tests ||= []
        @completed_tests << block
      end

      def completed_test_subscribers
        @completed_tests || []
      end
    end
  end
end