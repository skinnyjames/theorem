# frozen_string_literal: true

require_relative 'base'

module BeakerTests
  module BeforeEach
    # Basic before_each tests
    class BasicTest < BaseTest
      before_each do
        @before = :foo
      end

      test 'before each runs before the test' do
        expect(@before).to eql(:foo)
        @before = :bar
      end

      test 'will not leak state' do
        expect(@before).to eql(:foo)
      end
    end

    # before_all hooks are called in order
    class BeforeEachOverwrite < BaseTest
      before_all do
        @instance_variable = true
      end

      before_all do
        @instance_variable = false
      end

      test 'mutating in before each will overwrite' do
        expect(@instance_variable).to be(false)
      end
    end


    # Testing inherited state
    # state should not leak from one subclass to another
    class BaseState < BaseTest
      before_each do
        @fixture = :base
      end
    end

    # Override state
    class FirstState < BaseState
      before_each do
        @fixture = :first
      end

      test 'inherited state override' do
        expect(@fixture).to eql(:first)
      end
    end

    # Inherit state
    class SecondState < BaseState
      before_each do
        expect(@fixture).to eql(:base)
      end

      test 'state is inherited' do
        expect(@fixture).to eql(:base)
      end
    end
  end
end