# frozen_string_literal: true

module Test
  # test for shared examples
  class ExperimentTests < Theorem::Experiment
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

  # test for leaky state
  class OtherExperiments < Theorem::Experiment
    test 'does not leak state from prior experiments' do |name:, item: nil|
      expect(name).to eql('ruby')
      expect(item).to be(nil)
      expect(@foo).to be(nil)
    end
  end

  # the test
  class TestExperiment < Base
    before_all do
      @baz = :buzz
    end

    experiments ExperimentTests, item: true do
      include RSpec::Matchers
      before_all do
        @foo = :baz
      end
    end

    experiments OtherExperiments, name: 'ruby' do
      include RSpec::Matchers
    end
  end
end
