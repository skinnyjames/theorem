# frozen_string_literal: true

require_relative './base_test'

# test case
class TestCase < BaseTest
  before_all do
    @blue = true
  end

  test '#before_all' do
    expect(@blue).to eql(true)
  end

  test 'parent before_all' do
    test = 1
    expect(test).to eql(1)
    expect(@hello).to be(:world)
  end

  test 'methods' do
    expect(user).to eql({ one: 1, two: 2 })
  end

  def user
    { one: 1, two: 2 }
  end
end

# test case
class TestCase2 < BaseTest
  before_all do
    @red = true
  end

  test '#before_all will not leak state' do
    expect(@red).to eql(true)
    expect(@blue).to eql(nil)
  end

  test 'hello!' do
    expect(true).to be(true), "bad stuff"
  end
end