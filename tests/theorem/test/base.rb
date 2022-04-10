# frozen_string_literal: true

# Test module
#
# This group of tests are for the Hypothesis::Test object
# and tests behavior from the test class method
module Test
  class Base
    include Theorem::Hypothesis
    include RSpec::Matchers
  end
end
