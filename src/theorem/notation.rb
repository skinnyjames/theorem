# frozen_string_literal: true

module Theorem
  module Control
    class Notation
      def initialize(state = {})
        @state = state
      end

      def write(key, value)
        @state[key] = value
      end

      def read(key)
        @state[key]
      end

      def dump
        @state
      end

      def merge(notary)
        Notation.new(@state.merge(notary.dump))
      end

      def edit(key, &block)
        data = read(key)
        data = block.call(data)
        write(key, data)
      end
    end
  end
end