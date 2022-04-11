# frozen_string_literal: true

module Let
  class Test
    attr_accessor :stuff

    def initialize(value)
      @stuff = value
    end
  end

  class Persistence
    include Theorem::Hypothesis
    include RSpec::Matchers

    let_it_be(:class_1) do
      Test.new(:foo)
    end

    let_it_be(:class_2) do
      class_1
    end

    let(:example_1) do
      Test.new(:bar)
    end

    let(:example_2) do
      example_1
    end

    test 'can invoke let_it_be' do
      expect(example_class.stuff).to eql(:foo)
      expect(example.stuff).to eql(:bar)
      example_class.stuff = :buzz
      example.stuff = :bizz

      expect(example.stuff).to eql(:bizz)
      expect(example_class.stuff).to eql(:buzz)
    end

    test 'let does not leak state' do
      expect(example_2.stuff).to eql(:bar)
    end

    test 'let it be leaks state' do
      expect(class_2.stuff).to eql(:buzz)
    end

    test 'can invoke let' do
      expect(example.stuff).to eql(:bar)
    end

    def example_class
      class_2
    end

    def example
      example_2
    end
  end

  class WithBefore
    include Theorem::Hypothesis
    include RSpec::Matchers

    before_all do
      @user = :bob
    end

    before_all do
      @dwelling = :apartment
    end

    before_each do
      @car = :toyota
    end


    before_each do
      @color = :blue
    end

    let_it_be(:user) { @user }
    let(:color) { @color }
    let(:dwelling) { @dwelling }
    let_it_be(:car) { @car }


    test 'let can access instance vars' do
      expect(user).to eql(:bob)
      expect(color).to eql(:blue)
    end

    test 'and reverse' do
      expect(dwelling).to eql(:apartment)
      expect(car).to eql(:toyota)
    end
  end
end