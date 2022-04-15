# frozen_string_literal: true

module Tests
  module Failures
    # Failures::Sanity
    #
    # asserts that raising an error
    # will fail the test
    class Sanity < Base
      let(:klass) do
        Class.new do
          include Fixture
          include RSpec::Matchers

          test 'fail with a raised error' do
            raise StandardError, 'fail'
          end

          test 'fail with an rspec expectation' do
            expect(true).to be(false)
          end

          test 'returning false will not fail the test' do
            false
          end

          test 'returning nil will not fail the test' do

          end
        end
      end

      test 'raising an error will fail the test' do
        results = klass.run!.each_with_object({}) do |test, hash|
          hash[test.name] = test
        end

        aggregate_failures do
          expect(results['fail with a raised error'].failed?).to be(true)
          expect(results['fail with an rspec expectation'].failed?).to be(true)
          expect(results['returning false will not fail the test'].failed?).to be(false)
          expect(results['returning nil will not fail the test'].failed?).to be(false)
        end
      end
    end

    # Failures::Hook
    #
    # asserts that failures in hooks will
    # fail all the tests for that class
    class Hooks < Base

      TEST_HOOKS = %i[
        before_each
        before_all
        after_each
        after_all
     ].freeze

      TEST_HOOKS.each do |hook|
        let(hook) do
          Class.new do
            include Fixture

            send(hook) do
              raise StandardError, "fail in #{hook}"
            end

            test 'test #1' do
              nil
            end

            test 'test #2' do
              nil
            end
          end
        end

        test "an error in #{hook} will fail all the tests" do
          assert_failures send(hook).run!, hook.to_s
        end
      end

      let(:around) do
        Class.new do
          include Fixture
          include RSpec::Matchers

          around do |test|
            test.run!
            raise StandardError, 'fail in around'
          end

          test '#1' do
            nil
          end

          test '#2' do
            nil
          end
        end
      end

      test 'an error in around will fail all the tests' do
        assert_failures around.run!, 'around'
      end

      def assert_failures(results, hook)
        aggregate_failures do
          results.each do |result|
            expect(result.failed?).to be(true)
            expect(result.error.message).to eql("fail in #{hook}")
          end
        end
      end
    end
  end
end