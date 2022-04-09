# frozen_string_literal: true

module Theorem
  # shared examples
  class Experiment
    class << self
      def test(name, &block)
        @tests ||= []
        @tests << { name: name, block: block }
      end

      def tests(_experiment_namespace: to_s, **opts)
        @tests.map do |hash|
          Control::Test.new(hash[:name], _experiment_namespace, **opts, &hash[:block])
        end
      end
    end
  end
end