# frozen_string_literal: true

require_relative 'completed_test'
require_relative 'beaker'
require_relative 'registry'
require_relative 'test'

module Theorem
  module Control
    # control hypothesis
    module Hypothesis
      def self.included(mod)
        mod.define_singleton_method(:included) do |klass|
          klass.define_singleton_method(:control) do
            mod
          end

          klass.extend ClassMethods
          klass.instance_eval do
            @before_all ||= Beaker.new
            @tests = []
            @completed_tests = []
            @self = new
          end
          mod.add_to_registry(klass)
        end

        mod.const_set(:Beaker, Beaker)
        mod.const_set(:Test, Test)
        mod.const_set(:CompletedTest, CompletedTest)
        mod.extend(Registry)
      end
    end
  end
end

