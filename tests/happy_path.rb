# frozen_string_literal: true

require_relative '../src/hypothesis'
require 'rspec/expectations'

# test case
class TestCase
  include Hypothesis
  include RSpec::Matchers

  before_all do
    @blue = true
  end

  test '#before_all' do
    expect(@blue).to eql(true)
  end

  test 'methods' do
    expect(user).to eql({ one: 1, two: 2 })
  end

  def user
    { one: 1, two: 2 }
  end
end

puts TestCase.tests

TestCase.run!