# frozen_string_literal: true

require_relative 'completed_test'
require_relative 'beaker'
require_relative 'registry'
require_relative 'test'
require_relative 'let'

module Theorem
  module Control
    # control hypothesis
    module Hypothesis
      def self.included(mod)
        mod.define_singleton_method(:included) do |klass|
          klass.define_singleton_method(:control) do
            mod
          end

          klass.attr_reader :notary

          klass.define_method :initialize do
            @notary = Notation.new
          end

          klass.define_method :notate do |&block|
            block.call(@notary)
          end

          klass.extend Let
          klass.extend ClassMethods
          klass.instance_eval do
            @before_all ||= Beaker.new
            @before_each ||= Beaker.new
            @after_all ||= Beaker.new
            @after_each ||= Beaker.new
            @around = Flask.new
            @tests = []
            @completed_tests = []
            @self = new
          end
          mod.add_to_registry(klass)
        end

        mod.const_set(:Beaker, Beaker) unless mod.const_defined?(:Beaker)
        mod.const_set(:Test, Test) unless mod.const_defined?(:Test)
        mod.const_set(:CompletedTest, CompletedTest) unless mod.const_defined?(:CompletedTest)
        mod.extend(Registry)
      end
    end
  end
end

