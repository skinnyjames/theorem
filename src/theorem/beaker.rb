# frozen_string_literal: true

module Theorem
  module Control
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
  end
end
