# frozen_string_literal: true

module Tests
  module BeforeAll
    # BeforeAll::Sanity
    #
    # asserts that before_all state is available
    # to the tests
    class Sanity < Base
      before_all do
        @expected = :foo
      end

      test 'before_all state is available to the test' do
        expect(@expected).to eql(:foo)
        @expected = :bar
      end

      test 'before_all state does not leak from test to test' do
        expect(@expected).to eql(:foo)
      end
    end

    # BeforeAll::Override
    #
    # asserts that before_all state
    # can be overridden by consecutive before_all and before_each blocks
    class Override < Base
      before_all do
        @expected = :foo
      end

      before_all do
        @expected = :bar
      end

      test 'before_all can be overridden by before_all' do
        expect(@expected).to eql(:bar)
      end
    end

    # BeforeAll::Override
    #
    # asserts that before_all state
    # can be inherited
    class Inheritance < Base
      let(:parent) do
        Class.new do
          include Fixture
          include RSpec::Matchers

          before_all do
            @expected = :foo
          end
        end
      end

      let(:klass) do
        Class.new(parent) do
          test 'fixture with inherited before_all' do
            expect(@expected).to eql(:foo)
          end
        end
      end

      test 'before_all state can be inherited' do
        result = klass.run![0]
        expect(result.failed?).to be(false), result.error&.message
      end
    end

    # BeforeAll::InheritanceOverride
    #
    # asserts that inherited state from
    # before_all hooks can be overridden
    class InheritanceOverride < Base
      let(:grandparent) do
        Class.new do
          include Fixture
          include RSpec::Matchers

          before_all do
            @expected = :foo
          end
        end
      end

      let(:parent) do
        Class.new(grandparent) do
          before_all do
            expect(@expected).to eql(:foo)
            @expected = :bar
          end
        end
      end

      let(:klass) do
        Class.new(parent) do
          before_all do
            expect(@expected).to eql(:bar)
            @expected = :buzz
          end

          test 'inheritance fixture' do
            expect(@expected).to eql(:buzz)
          end
        end
      end

      test 'inherited before_each state can be overridden' do
        result = klass.run![0]
        expect(result.failed?).to be(false), result.error&.message
      end
    end
  end
end