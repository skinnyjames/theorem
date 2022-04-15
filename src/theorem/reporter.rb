# frozen_string_literal: true

module Theorem
  module Control
    # reporter mixin
    module Reporter
      def self.extended(mod)
        mod.extend(mod)
        mod.define_singleton_method :included do |root|
          subscriptions = mod.subscriptions || []
          subscriptions.each do |subscription, handler|
            mod.instance_exec root, subscription, handler do |root, sub, handle|
              root.send(sub, &handle)
            end
          end
        end
      end

      def subscribe(name, &block)
        @subscriptions ||= {}
        @subscriptions[name] = block
      end

      def subscriptions
        @subscriptions
      end
    end
  end
end