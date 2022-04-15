# frozen_string_literal: true

module Tests
  module Notation
    # Notation::Sanity
    #
    # asserts that notations can be
    # made from hooks and the test itself
    class Sanity < Base
      before_all do
        notate do |meta|
          # we can read, write, or edit key value pairs
          meta.write('before_all', 'Sean was here.')
        end
      end

      before_each do
        notate do |meta|
          meta.edit('before_all') do |string|
            "#{string} and again!"
          end
        end
      end

      test 'notation in test must be referenced from the test object' do |t|
        # notate by default will be called on the classes notation
        notation = notate do |meta|
          meta.read('before_all')
        end

        expect(notation).to eql('Sean was here. and again!')

        # call notate on the test object for test specific notations
        t.notate do |meta|
          meta.write('notation_test', 'only will be for this test')
        end
      end
    end

    # Notations::Hooks
    #
    # asserts that notations are on the
    # test result
    class Hooks < Base
      let(:klass) do
        Class.new do
          include Fixture

          before_each do
            notate do |meta|
              meta.write('before_each', true)
            end
          end

          before_all do
            notate do |meta|
              meta.write('before_all', true)
            end
          end

          after_each do
            notate do |meta|
              meta.write('after_each', true)
            end
          end

          after_all do
            notate do |meta|
              meta.write('after_all', true)
            end
          end

          test 'notate in test will be on the completed_test result' do |t|
            t.notate do |meta|
              meta.write('test', true)
            end
          end
        end
      end

      let(:results) { klass.run! }

      %w[before_all before_each after_each after_all test].each do |hook|
        test "notation in #{hook}" do |me|
          expect(results[0].notary[hook]).to be(true)
        end
      end
    end
  end
end