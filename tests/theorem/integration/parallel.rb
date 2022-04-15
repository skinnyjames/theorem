# frozen_string_literal: true

require 'parallel'
require 'tmpdir'

module Tests
  module Parallel
    # Parallel::Sanity
    #
    # asserts that a parallel run
    # has the expected results
    class Sanity < Base
      before_each do
        @results = []
      end

      let(:tmp) { Dir.mktmpdir }

      let(:harness) do
        LOAD_TESTS = -> { test1; test2; test3 }

        mod = Object.const_set("Mod#{SecureRandom.hex(5)}", Module.new)
        mod.include Theorem::Control::Harness
        mod.load_tests do
          LOAD_TESTS.call

          registry
        end
        mod.on_run do |tests|
          ::Parallel.map(tests, in_threads: 3, &:run!).flatten
        end

        mod.on_exit do |results|
          results
        end
        mod
      end

      let(:publisher) do
        mod = Object.const_set("Mod#{SecureRandom.hex(5)}", Module.new)
        mod.extend Theorem::Control::Reporter
        mod
      end

      let(:sandbox) do
        mod = Object.const_set("Mod#{SecureRandom.hex(5)}", Module.new)
        mod.include Theorem::Control::Hypothesis
        mod.include harness
        mod.include publisher
        mod
      end

      let(:fixture) do
        Class.new do
          attr_reader :closed

          attr_reader :urls

          def initialize
            @closed = false
            @urls = []
          end

          def closed?
            closed
          end

          def goto(url)
            @urls << url
          end

          def url
            @urls.last
          end

          def screenshot(path)
            raise StandardError, 'Handle closed' if closed?

            File.open(path, 'w') do |f|
              f << @urls.join("\n")
            end
          end

          def close
            @closed = true
          end
        end
      end

      let(:parent) do
        parent_sandbox = sandbox
        parent_fixture = fixture

        Class.new do
          include parent_sandbox
          include RSpec::Matchers

          before_all do
            @fixture = parent_fixture.new
          end

          after_each do |error:|
            expect(error).to be(nil)
            @fixture.screenshot 'stuff'
          end

          after_all do
            @fixture.close
          end
        end
      end

      let(:test1) do
        Class.new(parent) do
          before_each do
            @fixture.goto 'http://www.google.com'
          end

          test 'asserts url is google' do
            expect(@fixture.url).to include('google')
          end

          test 'asserts 2 urls' do
            expect(@fixture.urls.size).to be(2)
          end
        end
      end

      let(:test2) do
        Class.new(parent) do
          before_each do
            @fixture.goto 'http://www.yahoo.com'
          end

          test 'asserts url is yahoo' do
            expect(@fixture.url).to include('yahoo')
          end
        end
      end

      let(:test3) do
        Class.new(test2) do
          before_each do
            expect(@fixture.url).to eql('http://www.yahoo.com')
          end

          test 'asserts url is yahoo' do
            expect(@fixture.url).to include('yahoo')
          end
        end
      end

      test 'no tests should fail' do
        results = sandbox.run!
        aggregate_failures do
          expect(results.size).to be(4)
          results.each do |result|
            expect(result.failed?).to be(false), result.error&.message
            expect(result.name).to include('asserts')
          end
        end
      end
    end
  end
end