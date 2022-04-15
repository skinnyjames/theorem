# frozen_string_literal: true

module Tests
  # tests hooks interaction
  module Hooks
    # Hooks::State
    #
    # asserts combinations
    # of hook state
    class State < Base
      before_all do
        @outer = :foo
        @inner = :bar
      end

      before_each do
        @inner = :buzz
      end

      test 'hook state can be combined' do
        # tests has all state from hooks
        expect(@inner).to eql(:buzz)
        expect(@outer).to eql(:foo)

        # test can set state for after_each but not_after_all
        @outer = :bar
      end

      after_each do
        # after_each gets test state
        expect(@inner).to eql(:buzz)
        expect(@outer).to be(:bar)
      end

      after_all do
        # after_all gets before_all state
        expect(@inner).to be(:bar)
        expect(@outer).to be(:foo)
      end
    end
  end
end