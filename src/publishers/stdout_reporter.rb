# frozen_string_literal: true

require_relative '../theorem/reporter'

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

    subscribe :test_finished do |test|
      print test.failed? ? 'x'.red : '.'.green
    end

    subscribe :suite_finished do |results, duration|
      puts "\n"
      report_summary(results)

      failed_tests = results.select(&:failed?)

      report_failures(failed_tests)

      puts "\nTotal time: #{duration} seconds"
      puts "Total tests: #{results.size}\n"
    end

    def inflate_percentiles(tests)
      sorted = tests.sort_by(&:duration)
      tests.each_with_object([]) do |test, arr|
        _, below = sorted.partition do |duration_test|
          test.duration >= duration_test.duration
        end
        hash = {}
        hash[:percentile] = (below.size.to_f / sorted.size.to_f) * 100
        hash[:test] = test
        arr << hash
      end
    end

    def report_summary(tests)
      inflated = inflate_percentiles(tests)

      top_20 = 80 / (100.0 * (tests.size + 1).to_f)
      lowest_20 = 20 / (100.0 * (tests.size + 1).to_f)

      inflated.each do |test|
        icon = test[:test].failed? ? '❌'.red : '✓'.green
        puts "#{icon} #{test[:test].full_name.blue} : #{duration(test)}"
      end
    end

    def duration(test)
      str = "#{format('%<num>0.10f', num: test[:test].duration)} seconds"
      rank = ((test[:percentile] / 100) * (test[:test].duration + 1)) * 100
      if rank < 5
        str.red
      elsif rank > 95
        str.green
      elsif rank < 10
        str.yellow
      else
        str
      end
    end

    def report_failures(tests)
      tests.each do |failure|
        puts "Failure in #{failure.full_name}\nError: #{failure.error.message.to_s.red}\nBacktrace:\n------\n#{failure.error.backtrace.map(&:red).join("\n")}"
      end
    end
  end
end