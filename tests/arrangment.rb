# frozen_string_literal: true

require 'rspec/expectations'

require 'simplecov'
require 'simplecov-html'
require 'simplecov-cobertura'

SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([SimpleCov::Formatter::CoberturaFormatter, SimpleCov::Formatter::HTMLFormatter])
SimpleCov.start do
  add_filter '/tests/'
end

require_relative '../src/theorem'

module Fixture
  include Theorem::Control::Hypothesis
end

Theorem.run!(
  {
    directory: '/tests/test',
    require: [],
    module: 'Theorem::Hypothesis',
    harness: 'Theorem::Harness',
    publisher: ['Theorem::StdoutReporter']
  }
)

