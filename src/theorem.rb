require_relative 'theorem/hypothesis'
require_relative 'experiment'

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
    raise error unless error.is_a?(StandardError) || custom_exceptions.include?(error.class)
  end

  module Hypothesis
    include Control::Hypothesis
  end
end