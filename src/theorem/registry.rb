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

      def on_extra_event(&block)
        @extra_events ||= []
        @extra_events << block
      end

      def extra_event_subscribers
        @extra_events || []
      end

      def on_completed_test(&block)
        @completed_tests ||= []
        @completed_tests << block
      end

      def completed_test_subscribers
        @completed_tests || []
      end

      def on_completed_suite(&block)
        @completed_suites ||= []
        @completed_suites << block
      end

      def completed_suite_subscribers
        @completed_suites || []
      end
    end
  end
end