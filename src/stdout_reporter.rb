# frozen_string_literal: true

require_relative './theorem/reporter'

module Theorem
  module StringRefinements
    refine String do
      # colorization
      def colorize(color_code)
        "\e[#{color_code}m#{self}\e[0m"
      end

      def red
        colorize(31)
      end

      def green
        colorize(32)
      end

      def yellow
        colorize(33)
      end

      def blue
        colorize(34)
      end

      def pink
        colorize(35)
      end

      def light_blue
        colorize(36)
      end
    end
  end

  # Default Stdout reporter
  module StdoutReporter
    extend Control::Reporter
    using StringRefinements

    subscribe :on_completed_test do |test|
      print test.failed? ? 'x'.red : '.'.green
    end

    subscribe :on_completed_suite do |results|
      puts "\n"
      report_summary(results)

      failed_tests = results.select(&:failed?)

      report_failures(failed_tests)
    end

    def report_summary(tests)
      tests.each do |test|
        icon = test.failed? ? '❌'.red : '✓'.green
        puts "#{icon} #{test.full_name.blue}"
      end
    end

    def report_failures(tests)
      tests.each do |failure|
        puts "Failure in #{failure.full_name}\nError: #{failure.error.message.to_s.red}\nBacktrace:\n------\n#{failure.error.backtrace.map(&:red).join("\n")}"
      end
    end
  end
end