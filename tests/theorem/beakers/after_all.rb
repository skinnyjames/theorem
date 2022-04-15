# frozen_string_literal: true

module Tests
  module AfterAll
    # AfterAll::Sanity
    #
    # asserts that test state is
    # NOT available in after_all hooks
    class Sanity < Base
      after_all do
        expect(@expected).not_to eql(:foo)
      end

      test 'test state is not available in after_all hook' do
        @expected = :foo
      end
    end

    # AfterAll::Order
    #
    # asserts that after_all hooks
    # run in reverse order
    class Order < Base
      after_all do
        expect(@expected).to eql(:foo)
      end

      after_all do
        @expected = :foo
      end

      test 'after_all hooks run in reverse order' do
        expect(true).to be(true)
      end
    end

    # AfterAll::Inheritance
    #
    # asserts that after_all hooks
    # can be inherited
    class Inheritance < Base
      let(:parent) do
        Class.new do
          include Fixture
          include RSpec::Matchers

          after_all do
            expect(@expected).to eql(:bar)
          end
        end
      end

      let(:klass) do
        Class.new(parent) do
          after_all do
            @expected = :bar
          end

          test 'fixture test' do
            expect(true).to be(true)
          end
        end
      end

      test 'after_each state can be inherited' do
        result = klass.run![0]
        expect(result.failed?).to be(false)
      end
    end
  end
end