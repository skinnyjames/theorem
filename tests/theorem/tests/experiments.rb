# frozen_string_literal: true

module Tests
  # feeling useless, might deprecate soon; idk
  module Experiments
    # Experiments::Sanity
    #
    # asserts that block params and
    # before_state can be passed to experiments
    class Sanity < Base
      let(:klass) do
        Class.new(Theorem::Experiment) do
          test 'pulls in block parameters' do |item:|
            expect(item).to eql(true)
          end

          test 'pulls in arrangement from the before hook' do
            expect(@foo).to eql(:baz)
          end

          test 'does not pull in beakers from the containing class' do
            expect(@baz).to be(nil)
          end
        end
      end

      let(:klass2) do
        Class.new(Theorem::Experiment) do
          test 'does not leak state from prior experiments' do |item:|
            expect(item).to be(nil)
            expect(@foo).to be(nil)
            expect(@baz).to be(true)
          end
        end
      end

      experiments klass, item: true do
        include RSpec::Matchers
        before_all do
          @foo = :baz
        end
      end

      experiments klass2, item: nil do
        include RSpec::Matchers
        before_all do
          @baz = true
        end
      end
    end
  end
end