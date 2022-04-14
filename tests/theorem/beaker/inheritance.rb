# frozen_string_literal: true

require_relative 'base'

module BeakerTests
  class Inheritance < BaseTest
    let(:grandparent) do
      Class.new do
        include Fixture
        include RSpec::Matchers

        before_each do
          @one = :one
        end
      end
    end

    let(:parent) do
      Class.new(grandparent) do
        before_each do
          expect(@one).to eql(:one)
          @one = :two
        end
      end
    end

    let(:klass) do
      Class.new(parent) do
        before_each do
          expect(@one).to eql(:two)
          @one = :three
        end

        test 'inheritance' do
          expect(@one).to eql(:three)
        end
      end
    end

    let(:results) { klass.run! }

    test 'can inherit before_each hooks' do
      expect(results[0].failed?).to be(false), "Failed in before_each #{results[0].error&.message}"
    end
  end

  class InhertianceWithInstanceVariables < BaseTest
    before_each do
      @grandparent = Class.new do
        include Fixture
        include RSpec::Matchers

        before_each do
          @one = :one
        end
      end

      @parent = Class.new(@grandparent) do
        before_each do
          expect(@one).to eql(:one)
        end

        test 'inheritance' do
          expect(@one).to eql(:one)
        end
      end

      @klass = Class.new(@parent) do
        before_each do
          expect(@one).to eql(:one)
        end

        test 'inheritance' do
          expect(@one).to eql(:one)
        end
      end

      @result = @klass.run![0]
    end

    test 'can inherit before_each hooks' do
      expect(@result.failed?).to be(false), @result.error&.message
    end
  end

  class LetGrandparent < BaseTest
    let(:foo) { "bar" }
  end

  class LetParent < LetGrandparent
    let(:foo) { "foo_baz" }
  end

  class LetTest < LetParent
    let(:foo) { "bar_buzz" }

    test 'do thing' do
      expect(foo).to eql("bar_buzz")
    end
  end

  class LetInheritance < BaseTest
    let(:grandparent) do
      Class.new do
        include Fixture
        include RSpec::Matchers

        let(:foo) { 'baz_foo_bar' }
      end
    end

    let(:parent) do
      Class.new(grandparent) do
      end
    end

    let(:klass) do
      Class.new(parent) do

        test 'foo = baz_foo_bar' do
          expect(foo).to eql('baz_foo_bar')
        end
      end
    end

    let(:result) do
      klass.run![0]
    end

    test 'can override let' do
      expect(result.failed?).to be(false), result.error&.message
    end
  end
end