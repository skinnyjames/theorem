require_relative 'base'

module Notary
  module Notation
    class HookExperiments < Theorem::Experiment
      %w[before_all before_each after_each after_all test].each do |hook|
        test "notation in #{hook}" do
          expect(@result.notations[hook]).to be(true)
        end
      end
    end

    class Notate < Base
      experiments HookExperiments do
        include RSpec::Matchers
        before_all do
          klass = Class.new do
            include Fixture

            before_each do
              notate('before_each', true)
            end

            before_all do
              notate('before_all', true)
            end

            after_each do
              notate('after_each', true)
            end

            after_all do
              notate('after_all', true)
            end

            test 'notate in test will be on the completed_test result' do
              notation.write('test', true)
            end
          end

          @result = klass.run![0]
        end
      end
    end
  end
end