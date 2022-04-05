require_relative './hypothesis'
require 'extended_dir'

# module
module Theorem
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

      def self.run!(dir)
        test_cases = locate_tests(dir)
        total_count = test_cases.map do |test_case|
          test_case.tests.size
        end.inject(&:+)

        puts "Total tests #{total_count}"

        results = test_cases.map(&:run!).flatten

        puts "\n\nSummary\n-------"

        failed_tests = results.select(&:failed?)
        failed_tests.each do |failure|
          puts "Failure in #{failure.name}\nError: #{failure.error}\nBacktrace:\n------\n#{failure.error.backtrace.join("\n")}"
        end

        exit failed_tests.any? ? 1 : 0
      end
    end
  end
end
