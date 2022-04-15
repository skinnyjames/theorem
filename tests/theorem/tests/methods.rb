module Tests
  module Methods
    # Methods::Sanity
    #
    # asserts that tests have access
    # to methods
    class Sanity < Base
      test 'test blocks can access methods' do
        expect(foo).to eql(:bar)
      end

      def foo
        :bar
      end
    end

    # Methods::HookState
    #
    # asserts that methods have access to hook state
    class HookState < Base
      before_each do
        @foo = :bar
      end

      before_all do
        @bar = :buzz
      end

      test 'methods can access hook state' do
        expect(foo).to eql(:bar)
        expect(bar).to eql(:buzz)
      end

      attr_reader :foo, :bar
    end
  end
end