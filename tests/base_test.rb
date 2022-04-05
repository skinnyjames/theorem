require_relative '../src/hypothesis'
require 'rspec/expectations'

# base test
class BaseTest
  include Hypothesis
  include RSpec::Matchers
end