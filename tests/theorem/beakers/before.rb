# frozen_string_literal: true

module Tests
  module Before

    # Before::Sanity
    #
    # asserts that before_each runs
    # before before_all
    class Sanity < Base
      before_all do
        @expected = true
      end

      before_each do
        @expected = false
      end

      # rubocop:disable Style/CombinableLoops
      before_each do
        @second_expected = false
      end
      # rubocop:enable Style/CombinableLoops

      before_all do
        @second_expected = true
      end

      test 'before_each runs before_all regardless of the order in which it is declared' do
        expect(@expected).to be(false)
        expect(@second_expected).to be(false)
      end
    end

    # Before::EachCannotMutateAll
    #
    # asserts that before_each hooks
    # have access to before_all state
    class EachCanReadAll < Base
      let(:klass) do
        Class.new do
          include Fixture
          include RSpec::Matchers

          before_all do
            @expected = :foo
          end

          before_each do
            expect(@expected).to eql(:foo)
          end

          test 'fixture test' do
            expect(true).to be(true)
          end
        end
      end

      test 'before_each hooks can read before_all state' do
        result = klass.run![0]
        expect(result.failed?).to be(false), result.error&.message
      end
    end

    # Before::AllCannotReadEach
    #
    # asserts that before_all hooks
    # cannot read before_each state
    class AllCannotReadEach < Base
      let(:klass) do
        Class.new do
          include Fixture
          include RSpec::Matchers

          before_each do
            @expected = :foo
          end

          before_all do
            expect(@expected).to eql(:foo), 'mismatch'
          end

          test 'fixture test' do
            expect(true).to be(true)
          end
        end
      end

      test 'before_all hooks cannot read before_each state' do
        result = klass.run![0]
        expect(result.failed?).to be(true)
        expect(result.error.message).to eql('mismatch')
      end
    end
  end
end