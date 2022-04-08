# frozen_string_literal: true

require_relative 'base'

module BeakerTests
  module AroundHooks
    class BasicTest < BeakerTests::BaseTest

      around do |test|
        @state = :hello
        expect { test.run! }.to raise_error do |err|
          expect(err.class).to eql(StandardError)
          expect(err.message).to eql('error from test')
        end
      end

      test 'it should get around state' do
        raise StandardError, 'error from test'
      end
    end

    class StateTest < BeakerTests::BaseTest
      around do |test|
        @state = :hello
        test.run!
        expect(@state).to eql(:world)
      end

      test 'it can mutate state' do
        expect(@state).to eql(:hello)
        @state = :world
      end
    end

    class FailureFromHook < BeakerTests::BaseTest
      before_all do
        klass = Class.new do
          include Fixture
          around(&:run!)

          test 'failure state in an around hook is okay' do
            raise StandardError, 'error from test'
          end
        end
        @results = klass.run!
      end

      test 'failure in around hook' do
        error = @results[0].error
        expect(error).not_to be(nil)
        expect(error.message).to eql('error from test')
      end
    end
  end
end