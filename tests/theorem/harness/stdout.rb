# frozen_string_literal: true

module Harness
  # Stdout
  #
  # Tests the default harness behavior
  # of progress / summary output
  class Stdout < Base
    before_all do
      @first_test = Class.new do
        include Theorem::Hypothesis
      end
    end
  end
end