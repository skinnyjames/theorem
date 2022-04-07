# frozen_string_literal: true

module Theorem
  # shared examples
  class Experiment
    class << self
      def test(name, &block)
        @tests ||= []
        @tests << { name: name, block: block }
      end

      def tests(**opts)
        @tests.map do |hash|
          Control::Test.new(hash[:name], **opts, &hash[:block])
        end
      end
    end
  end
end