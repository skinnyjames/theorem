# frozen_string_literal: true

# entrypoint
module Hypothesis
  # beaker
  def self.registry
    @registry ||= []
  end

  def self.add_to_registry(klass)
    registry << klass
  end

  class Beaker
    def initialize
      @state = []
    end

    def run!(ctx)
      ctx.instance_exec @state, ctx do |state, ctx|
        state.each do |b|
          ctx.instance_eval &b
        end
      end
    end

    def prepare(&block)
      @state << block
    end
  end

  # test
  class Test
    def initialize(name, beaker, &block)
      @name = name
      @block = block
    end

    attr_reader :block

    def run!(ctx)
      ctx.instance_exec self, &block
    rescue Exception => ex
      ex
    end
  end

  def self.included(klass)
    klass.extend ClassMethods
    klass.instance_eval do
      @beaker = Beaker.new
      @tests = []
      @errors = []
      @self = new
    end
    Hypothesis.add_to_registry(klass)
  end

  # module
  module ClassMethods
    def inherited(klass)
      klass.include(Hypothesis)
      super
    end

    def before_all(&block)
      @beaker.prepare(&block)
    end

    def tests
      @tests
    end

    def test(name, &block)
      @tests << Test.new(name, @beaker, &block)
    end

    def run!
      test_case = new
      @beaker.run!(test_case)
      @tests.each do |test|
        error = test.run!(test_case)
        @errors << error if error
      end

      puts @errors
    end
  end
end
