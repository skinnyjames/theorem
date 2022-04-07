require_relative './theorem'
require 'extended_dir'

# module
module Theorem
  # module
  module Hypothesis
    on_completed_test do |test|
      print test.failed? ? 'X' : '.'
    end

    # harness
    class Harness
      def self.locate_tests(dir)
        ExtendedDir.require_all("./#{dir}")

        Hypothesis.registry
      end

      def self.get_test_count(test_cases)
        test_cases.map do |test_case|
          test_case.tests.size
        end.inject(&:+)
      end

      def self.report_failures(failed_tests)
        failed_tests.each do |failure|
          puts "❌ Failure in #{failure.full_name}\nError: #{failure.error}\nBacktrace:\n------\n#{failure.error.backtrace.join("\n")}"
        end
      end

      def self.report_passes(passing_tests)
        passing_tests.each do |pass|
          puts "✓ #{pass.full_name}"
        end
      end

      def self.run!(dir)
        test_cases = locate_tests(dir)
        total_count = get_test_count(test_cases)

        puts "Total tests #{total_count}"

        results = test_cases.each_with_object([]) do |test_case, memo|
          memo.concat test_case.run!
        end

        puts "\n\nSummary\n-------"

        failed_tests, passed_tests = results.partition(&:failed?)

        report_passes(passed_tests)
        report_failures(failed_tests)

        exit failed_tests.any? ? 1 : 0
      end
    end
  end
end
