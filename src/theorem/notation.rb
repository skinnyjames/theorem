# frozen_string_literal: true

module Theorem
  module Control
    class Notation
      def initialize
        @state = {}
      end

      def write(key, value)
        @state[key] = value
      end

      def read(key)
        @state[key]
      end

      def edit(key, &block)
        data = read(key)
        block.call(data)
        write(key, data)
      end

      def dump
        @state
      end

      def reset!
        @state = {}
      end
    end
  end
end