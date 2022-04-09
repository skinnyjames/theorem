# frozen_string_literal: true

require_relative 'base'

module BeakerTests
  module AfterEach
    class Sanity < BaseTest
      before_each do
        @foo = :bar
      end

      test 'after each will have mutated state from the test' do
        @foo = :baz
      end

      after_each do
        expect(@foo).to eql(:baz)
      end
    end
  end

  module AfterAll
    class Sanity < BaseTest
      before_all do
        @foo = :bar
      end

      test 'after all does not have mutated data from the test' do
        @foo = :baz
      end

      after_all do
        expect(@foo).not_to eql(:baz)
      end
    end

    # tests hook order
    class HookOrder < BaseTest
      before_all do
        @foo = :bar
      end

      after_all do
        expect(@foo).to eql(:buzz)
      end

      after_all do
        expect(@foo).to eql(:baz)
        @foo = :buzz
      end

      after_all do
        expect(@foo).to eql(:bar)
        @foo = :baz
      end

      test 'after all hooks run in the reverse order that they are declared' do
        @foo = :bar
      end
    end

    class BaseState < BaseTest
      after_all do
        expect(@foo).to eql(:buzz)
      end

      after_all do
        expect(@foo).to eql(:baz)
        @foo = :buzz
      end
    end

    class InheritedHookOrder < BaseState
      after_all do
        expect(@foo).to eql(:bar)
        @foo = :baz
      end

      before_all do
        @foo = :bar
      end

      test 'inherited after all hooks run in the reverse order that they are declared' do
        @foo = :hello
      end
    end
  end
end