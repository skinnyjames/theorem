require_relative './hypothesis'
require 'extended_dir'

# module
module Hypothesis
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

      test_cases.each(&:run!)
    end
  end
end