# frozen_string_literal: true

module Theorem
  # entrypoint
  module Hypothesis
    # beaker
    def self.registry
      @registry ||= []
    end

    def self.add_to_registry(klass)
      registry << klass
    end

    def self.on_completed_test(&block)
      @completed_tests ||= []
      @completed_tests << block
    end

    def self.completed_test_subscribers
      @completed_tests
    end

    class Beaker
      def initialize
        @state = []
      end

      def run!(ctx)
        ctx.instance_exec @state, ctx do |state, ctx|
          state.each do |b|
            ctx.instance_eval &b
          end
        end
      end

      def prepare(&block)
        @state << block
      end
    end

    # error class
    class CompletedTest
      attr_reader :name, :error

      def initialize(name, error = nil)
        @name = name
        @error = error
      end

      def failed?
        !@error.nil?
      end
    end


    # test
    class Test
      def initialize(name, beaker, &block)
        @name = name
        @block = block
      end

      attr_reader :block, :name

      def run!(ctx)
        ctx.instance_exec self, &block
        nil
      rescue Exception => ex
        ex
      end
    end

    def self.included(klass)
      klass.extend ClassMethods
      klass.instance_eval do
        @before_all ||= Beaker.new
        @tests = []
        @completed_tests = []
        @self = new
      end
      Hypothesis.add_to_registry(klass)
    end

    # module
    module ClassMethods
      def inherited(klass)
        klass.include(Hypothesis)
        klass.instance_exec self do |me|
          @parent_before_all ||= []
          @parent_before_all << me.before_all_beaker
        end
        super
      end

      def before_all(&block)
        @before_all.prepare(&block)
      end

      def tests
        @tests
      end

      def before_all_beaker
        @before_all
      end

      def test(name, &block)
        @tests << Test.new(name, @before_all, &block)
      end

      def run!
        test_case = new
        @parent_before_all&.each do |beaker|
          beaker.run!(test_case)
        end
        @before_all.run!(test_case)
        results = []
        @tests.each do |test|
          error = test.run!(test_case)
          completed_test = CompletedTest.new(test.name, error)
          publish_test_completion(completed_test)
          results << completed_test
        end
        results
      end

      private

      def publish_test_completion(completed_test)
        Hypothesis.completed_test_subscribers.each do |subscriber|
          subscriber.call(completed_test)
        end
      end
    end
  end
end
