# frozen_string_literal: true

module Tests
  module Around
    # AroundSanity
    #
    # asserts that around hooks
    # can invoke run of tests
    class Sanity < Base
      around &:run!

      test 'around can invoke the run of the test' do
        expect(true).to be(true)
      end
    end
  end

  # Around::State
  #
  # asserts that tests can
  # access and set around state
  class State < Base
    around do |test|
      @expected = :foo
      test.run!
      expect(@expected).to eql(:bar)
    end

    test 'tests have access to around state' do
      expect(@expected).to eql(:foo)
      @expected = :bar
    end
  end

  # Around::HookState
  #
  # asserts that around hooks
  # can access before state
  # and set after_each state
  # (but not after_all state)
  class HookState < Base
    before_all do
      @before_all = true
    end

    before_each do
      @before_each = true
    end

    after_each do
      expect(@after).to be(true)
    end

    # will not affect after_all state
    after_all do
      expect(@after).to be(nil)
    end

    around do |test|
      expect(@before_all).to be(true)
      expect(@before_each).to be(true)
      test.run!
      @after = true
    end

    test 'around can get and set hook state' do
      nil
    end
  end
end