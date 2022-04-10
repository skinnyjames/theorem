# frozen_string_literal: true

require_relative './theorem/harness'

# harness
module Theorem
  # default test harness
  module Harness
    include Control::Harness

    load_tests do |options|
      directory = options[:directory] || '.'

      ExtendedDir.require_all("./#{directory}")

      filtered_registry(options)
    end
  end
end
