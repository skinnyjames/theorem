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

            inner.suite_started_subscribers.each do |subscriber|
              subscriber.call tests.map(&:tests).flatten.map do |test|
                { name: test.name, metadata: test.metadata }
              end
            end

            starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
            results = inner.instance_exec tests, options, &mod.run_loader
            ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)

            duration = ending - starting

            inner.suite_finished_subscribers.each do |subscriber|
              subscriber.call(results, duration)
            end

            inner.instance_exec results, &mod.run_exit
          end
        end
      end

      # harness helpers
      module ClassMethods

        def load_tests(&block)
          @on_load_tests = block
        end

        def on_exit(&block)
          @on_exit = block
        end

        def on_run(&block)
          @on_run = block
        end

        def run_exit
          @on_exit || default_exit
        end

        def run_loader
          @on_run || default_runner
        end

        def test_loader
          @on_load_tests || default_loader
        end

        private

        def default_exit
          lambda do |results|
            exit results.any?(&:failed?) ? 1 : 0
          end
        end

        def default_loader
          lambda do |options|
            directory = options[:directory] || '.'

            ExtendedDir.require_all("./#{directory}")

            registry
          end
        end

        def default_runner
          lambda do |tests, options|
            tests.each_with_object([]) do |test, memo|
              memo.concat test.run!
            end
          end
        end
      end
    end
  end
end
