# frozen_string_literal: true

# Harness
#
# Test for the default harness behavior
# as well as reporting
module Harness
  class Base
    include Theorem::Hypothesis
    include RSpec::Matchers
  end
end
