# frozen_string_literal: true

# BeakerTests
#
# This group of tests validate
# the setup hook blocks, which are stored
# in objects called Hypothesis::Beakers
module BeakerTests
  class BaseTest
    include Theorem::Hypothesis
    include RSpec::Matchers

  end
end
