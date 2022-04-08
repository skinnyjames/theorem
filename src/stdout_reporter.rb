# frozen_string_literal: true

require_relative './theorem/reporter'

module Theorem
  # Default Stdout reporter
  module StdoutReporter
    extend Control::Reporter

    subscribe :on_completed_test do |test|
      print test.failed? ? 'x' : '.'
    end

    subscribe :on_completed_suite do |results|
      puts "\n"
      report_summary(results)

      failed_tests = results.select(&:failed?)

      report_failures(failed_tests)
    end

    def report_summary(tests)
      tests.each do |test|
        icon = test.failed? ? '❌' : '✓'
        puts "#{icon} #{test.full_name}"
      end
    end

    def report_failures(tests)
      tests.each do |failure|
        puts "Failure in #{failure.full_name}\nError: #{failure.error}\nBacktrace:\n------\n#{failure.error.backtrace.join("\n")}"
      end
    end
  end
end