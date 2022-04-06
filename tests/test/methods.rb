# frozen_string_literal: true

require_relative './base'

module Test
  # Test::Methods
  #
  # This class tests interacting with methods
  # from the test
  class Methods < Base
    test 'can reference methods from the test' do
      expect(fixture).to eql({ one: 1, two: 2 })
    end

    def fixture
      { one: 1, two: 2 }
    end
  end
end
