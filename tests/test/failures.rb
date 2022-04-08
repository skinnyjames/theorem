# frozen_string_literal: true

require_relative './base'

module Test
  # Test::Failures
  #
  # This class tests failure handling from
  # the tests blocks
  class Failures < Base
    before_all do
      @test_class = Class.new do
        include Fixture
        include RSpec::Matchers

        test 'raises an error' do
          raise StandardError, 'this is an error'
        end

        test 'works with rspec expectations' do
          expect(true).to be(false), 'rspec error'
        end

        test 'works with aggregate failures?' do
          aggregate_failures do
            expect(true).to be(false), 'first error'
            expect(true).to be(false), 'second error'
          end
        end
      end

      @results = @test_class.run!
    end

    test 'raising an error will fail the test' do
      result = @results[0]
      expect(result.error).not_to be(nil)
      expect(result.error.class).to be(StandardError)
      expect(result.error.message).to eql('this is an error')
    end

    test 'rspec expectations will fail the test' do
      result = @results[1]
      expect(result.error).not_to be(nil)
      expect(result.error.class).to be(RSpec::Expectations::ExpectationNotMetError)
      expect(result.error.message).to eql('rspec error')
    end

    test 'works with rspec aggregate failures' do
      result = @results[2]
      expect(result.error).not_to be(nil)
      expect(result.error.class).to be(RSpec::Expectations::MultipleExpectationsNotMetError)
      expect(result.error.message).to match(/Got 2 failures from failure aggregation block/)
    end
  end

  # failure in after each hook
  class AferEachFailuresOrder1 < Base
    before_all do
      test_class = Class.new do
        include Fixture

        after_each do
          raise StandardError, 'last error'
        end

        after_each do
          nil
        end

        test 'do the thing' do
          nil
        end
      end

      @results = test_class.run!
    end

    test 'failures in after each will fail the test' do
      error = @results[0].error
      expect(error.message).to eql('last error')
      expect(error.class).to eql(StandardError)
    end
  end

  class AfterEachFailuresOrder2 < Base
    before_all do
      test_class = Class.new do
        include Fixture

        after_each do
          raise StandardError, 'last error'
        end

        after_each do
          raise StandardError, 'first error'
        end

        test 'do the thing' do
          nil
        end
      end

      @results = test_class.run!
    end

    test 'failures in after each run in order' do
      error = @results[0].error
      expect(error.message).to eql('first error')
      expect(error.class).to eql(StandardError)
    end
  end

  # fail before hook
  class BeforeHookFailures < Base
    before_all do
      @test_class = Class.new do
        include Fixture
        include RSpec::Matchers

        before_all do
          raise RuntimeError, 'before hook error'
        end

        test 'test 1r' do
          expect(true).to be(true)
        end

        test 'test 2' do
          expect(true).to be(true)
        end
      end

      @results = @test_class.run!
    end

    test 'captures error in before hook' do
      result_1, result_2 = *@results
      aggregate_failures do
        expect(result_2.error.message).to eql('before hook error')
        expect(result_1.error.message).to eql('before hook error')
      end
    end
  end

  # Before each failures
  class BeforeEachFailures < Base
    before_all do
      @test_class = Class.new do
        include Fixture
        include RSpec::Matchers

        before_each do
          raise StandardError, 'before each error'
        end

        test 'test 1r' do
          expect(true).to be(true)
        end

        test 'test 2' do
          expect(true).to be(true)
        end
      end

      @results = @test_class.run!
    end

    test 'captures error in before hook' do
      result_1, result_2 = *@results
      aggregate_failures do
        expect(result_2.error.message).to eql('before each error')
        expect(result_1.error.message).to eql('before each error')
      end
    end
  end
end
