# frozen_string_literal: true

require_relative './theorem/harness'

# harness
module Theorem
  # default test harness
  module Harness
    include Control::Harness

    load_tests do |options|
      directory = options[:directory] || '.'

      ExtendedDir.require_all("./#{directory}")

      filtered_registry(options)
    end
  end

  # module retry harness
  module RetryHarness
    include Control::Harness

    on_run do |tests|
      arr_of_tests = tests.map { |test| { test: test, index: 0 } }

      final_results = []
      arr_of_tests.each do |test|
        test[:index] += 1
        results = test[:test].run!
        if results.any?(&:failed?) && test[:index] <= 3
          puts "Retrying iteration: #{test[:index]}\n#{results.map(&:full_name).join("\n")}"
          redo
        end
        final_results.concat results
      end

      final_results
    end
  end
end
