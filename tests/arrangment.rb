require 'simplecov'
require 'simplecov-cobertura'

SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
SimpleCov.start do
  add_filter '/tests/'
end

require 'rspec/expectations'
require_relative '../src/theorem'

module Fixture
  include Theorem::Control::Hypothesis
end