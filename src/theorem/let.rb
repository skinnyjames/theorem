# frozen_string_literal: true

module Theorem
  module Control
    # compatibility with let in rspec
    module Let
      def let(name, &block)
        setup_let(name, &block)
        instance_exec @let_registry do |registry|
          @before_each.prepare do
            define_singleton_method name do
              raise "can't find #{name}" unless registry[:let][name]

              registry[:let][name][:value] ||= instance_exec &registry[:let][name][:block]
            end
          end

          @after_each.prepare do
            registry[:let][name][:value] = nil
          end
        end
      end
      alias_method :each_with, :let

      def let_it_be(name, &block)
        setup_let(name, :let_it_be, &block)
        instance_exec @let_registry do |registry|
          @before_all.prepare do
            define_singleton_method name do
              raise "can't find #{name}" unless registry[:let_it_be][name]

              registry[:let_it_be][name][:value] ||= instance_exec &registry[:let_it_be][name][:block]
            end
          end
          @after_all.prepare do
            registry[:let_it_be][name][:value] = nil
          end
        end
      end
      alias_method :all_with, :let_it_be

      private

      def setup_let(name, type=:let, &block)
        @let_registry ||= {}
        @let_registry[type] ||= {}
        @let_registry[type][name] = { block: block, value: nil }

        define_singleton_method name do
          raise "can't find #{name}" unless @let_registry[type][name]

          @let_registry[type][name][:value] ||= @let_registry[type][name][:block].call
        end
      end
    end
  end
end