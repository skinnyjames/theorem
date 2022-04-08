require_relative 'theorem/hypothesis'
require_relative 'experiment'

module Theorem
  # RSpec subclasses Exception, so the only way to catch them without a dependency is to catch Exception
  CUSTOM_EXCEPTIONS = %w[
    RSpec::Expectations::ExpectationNotMetError
    RSpec::Expectations::MultipleExpectationsNotMetError
  ].freeze

  def self.handle_exception(error)
    raise error unless error.is_a?(StandardError) || CUSTOM_EXCEPTIONS.include?(error.class.to_s)
  end

  module Hypothesis
    include Control::Hypothesis
  end
end