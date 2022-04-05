require_relative '../src/hypothesis'
require 'rspec/expectations'
require 'watir'

# base test
class BaseTest
  include Theorem::Hypothesis
  include RSpec::Matchers

  before_all do
    @hello = :world
  end
end