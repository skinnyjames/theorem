# frozen_string_literal: true

module Theorem
  module Control
    # test object for around hooks
    class FlaskTest
      def initialize(test, ctx)
        @test = test
        @ctx = ctx
      end

      def name
        @test.name
      end

      def run!
        @test.run!(@ctx)
      end
    end

    # single use container
    class Flask
      attr_reader :state

      def initialize
        @state = nil
      end

      def run!(test, ctx, flask_test: FlaskTest.new(test, ctx))
        ctx.instance_exec flask_test, &@state
        nil
      rescue Exception => error
        Theorem.handle_exception(error)

        error
      end

      def empty?
        @state.nil?
      end

      def prepare(&block)
        @state = block
      end
    end

    # reusable container
    class Beaker
      def initialize
        @state = []
      end

      def clone
        @state.map!(&:clone)
        self
      end

      def reverse_run!(ctx)
        ctx.instance_exec @state.reverse, ctx do |state, ctx|
          state.each do |b|
            ctx.instance_eval &b
          end
        end
      end

      def run!(ctx)
        ctx.instance_exec @state, ctx do |state, ctx|
          state.each do |b|
            ctx.instance_eval &b
          end
        end
      end

      def empty?
        @state.empty?
      end

      def concat(beaker)
        @state.concat beaker.instance_variable_get('@state')
      end

      def prepare(&block)
        @state << block
      end
    end
  end
end
