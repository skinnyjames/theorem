# frozen_string_literal: true

module Notary
  class Base
    include Theorem::Hypothesis
    include RSpec::Matchers
  end
end