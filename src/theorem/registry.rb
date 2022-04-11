# frozen_string_literal: true

module Theorem
  module Control
    module Registry
      # beaker
      def registry
        @registry ||= []
      end

      def filtered_registry(options)
        registry.each do |test_class|
          if options[:include]&.any?
            test_class.tests.select! do |test|
              test.metadata[:tags]&.intersection(options[:include])&.any?
            end
          end

          next unless options[:exclude]&.any?

          test_class.tests.reject! do |test|
            test.metadata[:tags]&.intersection(options[:include])&.any?
          end
        end
      end

      def add_to_registry(klass)
        registry << klass
      end

      %i[suite_started test_started test_finished suite_finished].each do |method|
        define_method method do |&block|
          instance_variable_set("@#{method}_subscribers", []) unless instance_variable_get("@#{method}_subscribers")
          instance_variable_get("@#{method}_subscribers").append(block)
        end

        define_method "#{method}_subscribers" do
          return [] unless instance_variable_get("@#{method}_subscribers")

          instance_variable_get("@#{method}_subscribers")
        end
      end
    end
  end
end