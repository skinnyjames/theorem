# frozen_string_literal: true
require_relative './beaker'

module Theorem
  module Control
    # test new
    class Test
      def initialize(name, namespace, **opts, &block)
        @name = name
        @namespace = namespace
        @block = block
        @arguments = opts
      end

      attr_reader :block, :name, :arguments, :namespace

      def full_name
        "#{namespace} #{name}"
      end

      def run!(ctx)
        ctx.instance_exec self, **arguments, &block
        nil
      rescue Exception => ex
        ex
      end
    end

    # module
    module ClassMethods
      def inherited(klass)
        klass.include(control)
        klass.instance_exec self do |me|
          @parent_before_all ||= []
          @parent_before_all << me.before_all_beaker
        end
        super
      end

      def before_all(&block)
        @before_all.prepare(&block)
      end

      def tags(*args)
        @tags = args
      end

      def experiments(klass, **opts, &block)
        obj = Class.new
        obj.include(control)
        obj.instance_eval &block if block
        obj.instance_exec klass, opts do |experiment_klass, params|
          @tests.concat experiment_klass.tests(**params)
        end
      end

      def get_tags
        @tags
      end

      def tests
        @tests
      end

      def before_all_beaker
        @before_all
      end

      def test(name, &block)
        @tests << Test.new(name, to_s, &block)
      end

      def run!
        test_case = new

        before_failures = run_before_all_beakers(test_case)
        if before_failures.any?
          return before_failures
        end

        results = []
        @tests.each do |test|
          error = test.run!(test_case)
          completed_test = CompletedTest.new(test, error)
          publish_test_completion(completed_test)
          results << completed_test
        end
        results
      end

      private

      def run_before_all_beakers(test_case)
        @parent_before_all&.each do |beaker|
          beaker.run!(test_case)
        end
        @before_all.run!(test_case)
        []
      rescue Exception => error
        @tests.map do |test|
          CompletedTest.new(test, error)
        end
      end

      def publish_test_completion(completed_test)
        control.completed_test_subscribers.each do |subscriber|
          subscriber.call(completed_test)
        end
      end

    end
  end
end