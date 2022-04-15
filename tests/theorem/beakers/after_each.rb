# frozen_string_literal: true

module Tests
  module AfterEach
    # AfterEach::Sanity
    #
    # asserts that test state is available in an after
    # each hook
    class Sanity < Base
      test 'after_each will have access to state from the test' do
        @expected = :foo
      end

      after_each do
        expect(@expected).to eql(:foo)
      end
    end

    # AfterEach::Order
    #
    # asserts that after_each hooks run
    # in reverse order
    class Order < Base
      after_each do
        expect(@expected).to eql(:bar)
      end

      # rubocop:disable Style/CombinableLoops
      after_each do
        expect(@expected).to eql(:foo)
        @expected = :bar
      end
      # rubocop:enable Style/CombinableLoops

      test 'after_each hooks run in the reverse order they are declared' do
        @expected = :foo
      end
    end

    # AfterEach::Inheritance
    #
    # asserts that after_each state
    # can be inherited
    class Inheritance < Base
      let(:parent) do
        Class.new do
          include Fixture
          include RSpec::Matchers

          after_each do
            expect(@expected).to eql(:bar)
          end
        end
      end

      let(:klass) do
        Class.new(parent) do
          after_each do
            @expected = :bar
          end

          test 'fixture test' do
            @expected = :foo
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