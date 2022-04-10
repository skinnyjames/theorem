# frozen_string_literal: true

require_relative 'base'

module BeakerTests
  # Tests for before_all
  class BeforeAll < BaseTest
    before_all do
      @instance_variable = true
      @instance_block = ->(greeting) { "Hello #{greeting}" }
    end

    before_all do
      @second_instance_variable = false
    end

    test 'instance variables persist in the test' do
      expect(@instance_variable).to be(true)
      @instance_variable = false
    end

    test 'before all does not leak state' do
      expect(@instance_variable).to be(true)
    end

    test 'instance blocks persist in the test' do
      expect(@instance_block['world']).to eql('Hello world')
    end

    test 'before_all can be called multiple times' do
      expect(@second_instance_variable).to be(false)
    end
  end

  # before_all hooks are called in order
  class BeforeAllOverwrite < BaseTest
    before_all do
      @instance_variable = true
    end

    before_all do
      @instance_variable = false
    end

    test 'mutating in before all will overwrite' do
      expect(@instance_variable).to be(false)
    end
  end

  # Testing inherited state
  # state should not leak from one subclass to another
  class BaseState < BaseTest
    before_all do
      @fixture = :base
    end
  end

  # Override state
  class FirstState < BaseState
    before_all do
      @fixture = :first
    end

    test 'inherited state override' do
      expect(@fixture).to eql(:first)
    end
  end

  # Inherit state
  class SecondState < BaseState
    test 'state is inherited' do
      expect(@fixture).to eql(:base)
    end
  end
end
