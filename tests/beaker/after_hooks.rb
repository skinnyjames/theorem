# frozen_string_literal: true

require_relative 'base'

module BeakerTests
  module AfterEach
    class Sanity < BaseTest
      before_each do
        @foo = :bar
      end

      test 'after each does not leak state' do
        @foo = :bar
      end

      after_each do
        expect(@foo).to eql(:bar)
      end
    end
  end

  module AfterAll
    class Sanity < BaseTest
      before_all do
        @foo = :bar
      end

      test 'after all has mutated data' do
        @foo = :baz
      end

      after_all do
        expect(@foo).to eql(:baz)
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

      test 'inherited after all hooks run in the reverse order that they are declared' do
        @foo = :bar
      end
    end
  end
end