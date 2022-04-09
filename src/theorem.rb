require_relative 'theorem/hypothesis'
require_relative 'harness'
require_relative 'experiment'
require_relative 'stdout_reporter'

require_relative 'theorem/harness'
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

  def self.run!(options)
    options[:require].each do |file|
      require file
    end

    raise StandardError, "Unknown Module: #{options[:module]}" unless defined? Object.const_get(options[:module])
    raise StandardError, "Unknown Harness: #{options[:harness]}" unless defined? Object.const_get(options[:harness])

    mod = Object.const_get(options[:module])
    harness = Object.const_get options[:harness]
    mod.include harness

    options[:publisher].each do |publisher|
      if defined? Object.const_get(publisher)
        mod.include Object.const_get(publisher)
      else
        raise StandardError, "Unknown Publisher: #{publisher}"
      end
    end

    mod.run!(options: options)
  end

  module JsonReporter
    extend Control::Reporter

    subscribe :on_completed_suite do |results|
      results = results.map do |result|
        { name: result.full_name, failed: result.failed? }
      end
      puts results.to_json
      puts "\n\n"
    end
  end

  module Hypothesis
    include Control::Hypothesis
  end
end