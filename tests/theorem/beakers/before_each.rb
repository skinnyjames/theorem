# frozen_string_literal: true

module Tests
  module BeforeEach
    # BeforeEach::Sanity
    #
    # asserts that instance variables in
    # a before_each block are accessible
    # from the test, and tests cannot share
    # before_each state
    class Sanity < Base
      before_each do
        @expected = :foo
      end

      test 'before each state is accessible from the test' do
        expect(@expected).to eql(:foo)
        @expected = :bar
      end

      test 'before each does not leak from test to test' do
        expect(@expected).to eql(:foo)
      end
    end

    # BeforeEach::Override
    #
    # asserts that instance variables in
    # successive before_each blocks can override each other
    class Override < Base
      before_each do
        @expected = :foo
      end

      # rubocop:disable Style/CombinableLoops
      before_each do
        @expected = :bar
      end
      # rubocop:enable Style/CombinableLoops

      test 'before each values can be overridden' do
        expect(@expected).to eql(:bar)
      end
    end

    # BeforeEach::Inheritance
    #
    # asserts that before_each contexts
    # are inherited from a super class
    class Inheritance < Base
      let(:parent) do
        Class.new do
          include Fixture
          include RSpec::Matchers

          before_each do
            @expected = :foo
          end
        end
      end

      let(:klass) do
        Class.new(parent) do
          test 'inheritance fixture' do
            expect(@expected).to eql(:foo)
          end
        end
      end

      test 'before_each state can be inherited' do
        result = klass.run![0]
        expect(result.failed?).to be(false), result.error&.message
      end
    end

    # BeforeEach::InheritanceOverride
    #
    # asserts that inherited before_each state be
    # overridden
    class InheritanceOverride < Base
      let(:grandparent) do
        Class.new do
          include Fixture
          include RSpec::Matchers

          before_each do
            @expected = :foo
          end
        end
      end

      let(:parent) do
        Class.new(grandparent) do
          before_each do
            expect(@expected).to eql(:foo)
            @expected = :bar
          end
        end
      end

      let(:klass) do
        Class.new(parent) do
          before_each do
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
