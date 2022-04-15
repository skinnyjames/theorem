# frozen_string_literal: true
require_relative './beaker'
require_relative 'notation'

module Theorem
  module Control
    # test new
    class Test
      def initialize(name, namespace, arguments: {}, **metadata, &block)
        @name = name
        @namespace = namespace
        @block = block
        @arguments = arguments
        @metadata = metadata
        @notary = Notation.new
      end

      attr_reader :block, :name, :arguments, :namespace, :metadata, :notary

      def full_name
        "#{namespace} #{name}"
      end

      def notate(&block)
        block.call(notary)
      end

      def run!(ctx)
        ctx.instance_exec self, **arguments, &block
      end
    end

    # module
    module ClassMethods
      def inherited(klass)
        klass.extend ClassMethods
        klass.include(control)
        klass.instance_exec self do |me|
          @parent_before_all ||= []
          @before_all.concat me.before_all_beaker.clone

          @parent_before_each ||= []
          @before_each.concat me.before_each_beaker.clone

          @parent_after_each ||= []
          @after_each.concat me.after_each_beaker.clone

          @parent_after_all ||= []
          @after_all.concat me.after_all_beaker.clone
        end
        super
      end

      def before_all(&block)
        @before_all.prepare(&block)
      end

      def around(&block)
        @around.prepare(&block)
      end

      def before_each(&block)
        @before_each.prepare(&block)
      end

      def after_each(&block)
        @after_each.prepare(&block)
      end

      def after_all(&block)
        @after_all.prepare(&block)
      end

      def experiments(klass, **opts, &block)
        obj = Class.new
        obj.include(control)
        obj.instance_eval &block if block
        obj.instance_exec self, klass, opts do |consumer, experiment_klass, params|
          @tests.concat experiment_klass.tests(_experiment_namespace: consumer.to_s, arguments: params)
        end
      end

      def tests
        @tests
      end

      def before_all_beaker
        @before_all
      end

      def before_each_beaker
        @before_each
      end

      def after_each_beaker
        @after_each
      end

      def after_all_beaker
        @after_all
      end

      def test(name, **hargs, &block)
        @tests << Test.new(name, to_s, **hargs, &block)
      end

      def run!
        return [] if @tests.empty?

        test_case = new

        # run before all beakers to create state in test case
        before_failures = run_before_all_beakers(test_case)

        if before_failures.any?
          before_failures.each do |failure|
            publish_test_completion(failure)
          end
          return before_failures
        end

        # duplicate the before_all arrangement for the after all hook
        duplicate_test_case = test_case.clone

        results = []
        @tests.each do |test|
          test_start = clock_time

          publish_test_start(test)

          error ||= run_before_each_beakers(test_case)

          before_test_case = test_case.clone
          error ||= run_test(test, before_test_case)
          error ||= run_after_each_beakers(before_test_case, error: error)

          notary = test_case.notary.merge(test.notary)

          duration = clock_time - test_start

          completed_test = CompletedTest.new(test, error, duration: duration, notary: notary.dump)

          # publish_early if there are no after_all beakers
          publish_test_completion(completed_test) if @after_all.empty?

          results << completed_test
        end

        after_failures = run_after_all_beakers(results, duplicate_test_case)

        if after_failures.any?
          after_failures.each do |failure|
            publish_test_completion(failure)
          end
          return after_failures
        end

        results.each do |completed_test|
          # merge any after_all notations
          completed_test.notary.merge!(duplicate_test_case.notary.dump)
          publish_test_completion(completed_test) unless @after_all.empty?
        end

        results
      end

      private

      def clock_time
        Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end

      def run_test(test, test_case)
        if @around.empty?
          begin
            test.run!(test_case)
            nil
          rescue Exception => error
            Theorem.handle_exception(error)

            error
          end
        else
          @around.run!(test, test_case)
        end
      end

      def run_after_all_beakers(results, test_case)
        @after_all.reverse_run!(test_case)

        []
      rescue Exception => error
        Theorem.handle_exception(error)

        results.each do |test|
          test.error = error
          test.notary = test_case.notary
        end

        results
      end

      def run_after_each_beakers(test_case, **params)
        @after_each.reverse_run!(test_case, **params)
        nil
      rescue Exception => error
        Theorem.handle_exception(error)

        error
      end

      def run_before_each_beakers(test_case)
        @before_each.run!(test_case)
        nil
      rescue Exception => error
        Theorem.handle_exception(error)

        error
      end

      def run_before_all_beakers(test_case)
        @before_all.run!(test_case)
        []
      rescue Exception => error
        Theorem.handle_exception(error)

        @tests.map do |test|
          CompletedTest.new(test, error, notary: test_case.notary)
        end
      end

      def publish_test_completion(completed_test)
        control.test_finished_subscribers.each do |subscriber|
          subscriber.call(completed_test)
        end
      end

      def publish_test_start(test)
        control.test_started_subscribers.each do |subscriber|
          subscriber.call(test)
        end
      end
    end
  end
end