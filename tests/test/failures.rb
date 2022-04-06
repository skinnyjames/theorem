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

        test 'raises an error' do
          raise StandardError, 'this is an error'
        end
      end
    end

    test 'raising an error will fail the test' do
      result = @test_class.run!&.first
      expect(result.error).not_to be(nil)
      expect(result.error.class).to be(StandardError)
      expect(result.error.message).to eql('this is an error')
    end
  end
end