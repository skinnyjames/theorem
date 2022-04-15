# frozen_string_literal: true

require 'securerandom'

module Tests
  module Let
    # Let::Sanity
    #
    # asserts that let is memoized
    class Sanity < Base
      let(:foo) { SecureRandom.hex(8) }

      before_each do
        @foo = foo
        expect(foo).to eql(foo)
      end

      test 'let is memoized' do
        expect(foo).to eql(@foo)
      end

      after_each do
        expect(foo).to eql(@foo)
      end
    end

    # Let::BeforeAll
    #
    # asserts that let is inaccessible in
    # before_all
    class BeforeAll < Base
      before_all do
        expect { foo }.to raise_error do |error|
          expect(error.message).to include('undefined')
        end
      end

      let(:foo) { :foo }

      test 'let is not accessible in before_all hooks' do
        expect(foo).to eql(:foo)
      end
    end

    # Let::Nesting
    #
    # asserts that let can reference other lets
    class Nesting < Base

      let(:outer) { SecureRandom.hex(9) }
      let(:inner) { "#{outer}_foo" }

      test 'can reference let definitions within let definitions' do
        expect(inner).to eql("#{outer}_foo")
      end
    end
  end

  module LetItBe
    # LetItBe::Sanity
    #
    # asserts that let_it be is memoized
    class Sanity < Base
      let_it_be(:foo) { SecureRandom.hex(8) }

      before_all do
        @foo = foo
      end

      before_all do
        expect(foo).to eql(foo)
      end

      test 'let it be is memoized' do
        expect(foo).to eql(@foo)
      end

      after_all do
        expect(foo).to eql(@foo)
      end
    end
  end
end