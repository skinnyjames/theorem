# frozen_string_literal: true

require_relative 'hypothesis'
require 'extended_dir'
module Theorem
  module Control
    # control harness
    module Harness
      def self.included(mod)
        mod.extend(ClassMethods)
        mod.define_singleton_method :included do |inner|
          inner.define_singleton_method :run! do |options: {}|
            tests = inner.instance_exec options, &mod.test_loader
            results = inner.instance_exec tests, options, &mod.run_loader
            inner.completed_suite_subscribers.each do |subscriber|
              subscriber.call(results)
            end
            exit results.any?(&:failed?) ? 1 : 0
          end
        end
      end

      # harness helpers
      module ClassMethods
        DEFAULT_LOADER = ->(options) do
          directory = options[:directory] || '.'

          ExtendedDir.require_all("./#{directory}")

          registry
        end

        DEFAULT_RUNNER = ->(tests, options) do
          tests.each_with_object([]) do |test, memo|
            memo.concat test.run!
          end
        end

        def load_tests(&block)
          @on_load_tests = block
        end

        def on_run(&block)
          @on_run = block
        end

        def run_loader
          @on_run || DEFAULT_RUNNER
        end

        def test_loader
          @on_load_tests || DEFAULT_LOADER
        end
      end
    end
  end
end
