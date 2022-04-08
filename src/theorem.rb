require_relative 'theorem/hypothesis'
require_relative 'harness'
require_relative 'experiment'
require_relative 'stdout_reporter'
require 'json'

module Theorem
  # RSpec subclasses Exception, so the only way to catch them without a dependency is to catch Exception
  def self.custom_exceptions
    errors = []
    if defined? RSpec::Expectations
      errors.concat [RSpec::Expectations::ExpectationNotMetError, RSpec::Expectations::MultipleExpectationsNotMetError]
    end
    errors
  end

  def self.handle_exception(error)
    unless error.is_a?(StandardError) || custom_exceptions.include?(error.class)
      raise error
    end
  end

  def self.run!(klass = Hypothesis, directory = '.', options = {})
    klass.run!(directory, options)
  end

  module JsonReporter
    extend Control::Reporter

    subscribe :on_completed_suite do |results|
      results = results.map do |result|
        { name: result.full_name, failed: result.failed? }
      end
      puts results
      puts "\n\n"
    end
  end

  module Hypothesis
    include Control::Hypothesis
    include Theorem::RetryHarness
    include StdoutReporter
  end
end