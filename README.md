# theorem

A modern test library & runner toolkit

## installation

`gem install theorem`

## basic usage

```ruby
# tests/exmaple.rb

# use rspec-excepectations for assertion library
require 'rspec/expectations'
# test.rb
class Example
  include Theorem::Hypothesis
  include RSpec::Matchers
  
  test 'asserts true' do
    expect(true).to be(true)
  end
end
```
each test class is capable of running itself (a concept that will come in handy later)

```ruby
results = Example.run!

results[0].failed? # false
results[0].full_name # Example asserts true
```

the test can also be run with the default harness/cli

``theorize --directory tests``

outputs 

```bash
.
✓ Example asserts true
```

### hooks

Theorem supports the following hooks
* before_all
* before_each
* around
* after_each
* after_all

Each hook (except for around) can be invoked multiple times, as well as inherited from a superclas

before hooks run in the order they are declared (starting with the superclass)

after_hooks run in the reverse order they are declared (ending with the superclass)

```ruby
require 'rspec/expectations'
# test.rb
class Example
  include Theorem::Hypothesis
  include RSpec::Matchers
  
  before_all do
    @before_all = true
  end
  
  before_each do
    @before_each = true
  end
  
  after_each do
    expect(@after_each).to eql(true)
  end
  
  after_all do
    expect(@after_all).to eql(true)
  end
  
  test 'asserts before_all' do
    expect(@before_all).to be(true)
    expect(@before_each).to be(true)
    
    @before_each = :mutated
    @before_all = :mutated
    
    @after_each = true
    @after_all = true
  end
  
  test 'asserts mutations in hooks' do
    expect(@before_all).to eql(:mutated) # before all leaks state into the cases
    expect(@before_each).to be(true) # before each does not
    
    @after_each = true
  end
end
```

### Experiments

Experiments are reusable tests cases that can be invoked with parameters and their own arrangement

These are similar to RSpec shared examples

```ruby
require 'rspec/expectations'

class CollectionExperiments < Theorem::Experiment
  test 'collection includes 7' do |subject:|
    expect(subject).to include(7)
  end
  
  test 'collection does not include 9' do |subject:|
    expect(subject).not_to include(9)
  end
  
  test 'collection responds to methods' do |subject:|
    @methods.each do |method|
      expect(subject.respond_to?(method)).to be(true)
    end
  end
end

module CollectionTest
  class SetTest
    include Theorem::Hypothesis

    experiments CollectionExperiments, subject: Set.new([1, 2, 7]) do
      include RSpec::Matchers

      # experiments can have their own state
      before_each do
        @methods = [:each, :map, :subset?]
      end
    end
  end

  class ArrayTest
    include Theorem::Hypothesis
    
    experiments CollectionExperiments, subject: Array.new([1, 2, 7]) do
      include RSpec::Matchers

      before_each do
        @methods = [:each, :map]
      end
    end
  end
end
```

outputs 
```shell
......
✓ CollectionTest::SetTest collection includes 7
✓ CollectionTest::SetTest collection does not include 9
✓ CollectionTest::SetTest collection responds to methods
✓ CollectionTest::ArrayTest collection includes 7
✓ CollectionTest::ArrayTest collection does not include 9
✓ CollectionTest::ArrayTest collection responds to methods
```

### Registry

As demonstrated earlier, test classes are capable of running themselves.

When loading a file that contains a class that includes `Theorem::Hypothesis`, 
you can get a list of the test classes with `Theorem::Hypothesis.registry`

`::registry` will return all the available tests, (a concept that will come in handy later)

### Sandboxing

Including `Theorem::Hypothesis` into a class, will allow that class to behave like a test
and add that test to the registry

You can also create your own test library module with it's own registry by including
`Theorem::Control::Hypothesis`

```ruby
# test/hello_world.rb
require 'rspec/expectations'

module Hello
  module World
    include Theorem::Control::Hypothesis
  end
end

class HelloWorldTest
  include Hello::World
  include RSpec::Matchers

  test 'asserts tautology' do
    expect(true).to be(true)
  end
end
```

you can then run it like:

`theorize --require ./test/hello_world.rb --module Hello::World`

the `theorize` command is requiring the file need to run the tests (similar to a spec_helper)
and we are also specifying the target module's registry that we want to run against.

Let's dig into this.

### Test Harnesses

in the above example, we created a sandboxed test library mixin with it's own registry

When the `theorize` command is run, it is doing a couple of other things to our target module

The target module is inflated with a default test harness and publisher (reporter)
This is the same as declaring the following:

```ruby
require 'rspec/expectations'

module Hello
  module World
    include Theorem::Control::Hypothesis
    include Theorem::Harness
    include Theorem::StdoutReporter
  end
end

class HelloWorldTest
  include Hello::World
  include RSpec::Matchers

  test 'asserts tautology' do
    expect(true).to be(true)
  end
end

```

Harnesses define 2 things:

* What tests to run 
* How the tests should be run

We can also create our own harness module by mixing in `Theorem::Control::Harness`

```ruby

# hello_world.rb

module Hello
  module Harness
    include Theorem::Control::Harness
    
    # load_tests will default to requiring every ruby file in the directory specified 
    # by the cli command (defaults to the current directory the command is run)
    
    load_tests do |options|
      # the block takes an options parameter
      # that is passed to the runner (theorize will pass cli options into here)
      
      # require the needed files
      require_relative 'tests/first_test.rb'
      
      # this method should return a list of test classes to run
      # it will default to the registry of the module it is included in
      registry
    end
    
    # on_run takes a list of the resolved test classes, as well as a second options parameter
    # that is passed by the runner
    on_run do |test_classes, options|
      # this method expects to return an array of CompletedTest objects
      test_classes.each_with_object([]) do |test_class, memo|
        memo.concat test_class.run!
      end
    end
  end
  
  module World
    include Theorem::Control::Hypothesis
    include Theorem::StdoutReporter
  end
end

# tests/first_test.rb
class HelloWorldTest 
  include Hello::World
  
  test 'fail this test' do
    raise StandardError, 'fail'
  end
end
```

now we can run these tests with

`theorize --require ./hello_world.rb --harness Hello::Harness --module Hello::World -d tests`

Which will run all the tests in the `tests/` directory using the `Hello::World` module with the `Hello::Harness` harness.

We could statically include the harness into the `World` module and run the harness with a vanilla ruby command as well.

The following example creates a parallel harness.

```ruby
# hello_world.rb
require 'parallel'

module Hello
  module ParallelHarness
    include Theorem::Control::Harness
    
    on_run do |tests|
      Parallel.map(tests, in_threads: 6, &:run!).flatten
    end
  end
  
  module World
    include Theorem::Control::Hypothesis
    include ParallelHarness
    include Theorem::StdoutReporter
  end
end

# can just run the tests programmatically
Hello::World.run! 
```

now we can run our tests with `ruby hello_world.rb`

Easy.

### Publishers / Reporters

Publishers are modules that extend `Theorem::Control::Reporter`

`Theorem::StdoutRepoter` is provided, but you can write your own.

They can subscribe to only the available events that they are interested in.

```ruby
require 'json'

module Hello
  module JsonReporter
    extend Theorem::Control::Reporter
    
    # on_completed_suite yields an array of CompletedTests from the run
    subscribe :on_completed_suite do |results|
      results = results.map do |result|
        { name: result.full_name, failed: result.failed? }
      end
      puts results.to_json
      puts "\n\n"
    end
  end
end
```

They can either be mixed in to the target module, or specified using the cli

`theorem --publisher Hello::JsonReporter`

you can include / specify as many publishers as you want.


### Metadata api

Tests can declare arbitrary keyword arguments which will be stored on the test as metadata

```ruby
class Test
  include Theorem::Hypothesis
  
  test 'test with metadata', some: true, data: [:ok], here: ->(something) { puts something } do
    raise StandardError, 'that is just too cool?'
  end
end
```

these can be processed by a harness

```ruby
# my_harness.rb
require 'theorem'

module MyHarness
  include Theorem::Control::Harness

  load_tests do |options|
    registry.each do |test_class|
      test_class.tests.each do |test|
        test.metadata[:here]&.call("wow") if test.metadata[:data]&.include? :ok
      end
    end

    registry
  end
end
```

and running `theorize --harness MyHarness --require my_harness.rb`

```shell
wow
x
❌ Test test with metadata
Failure in Test test with metadata
Error: that is just too cool?
Backtrace:
....
```

The theorize cli and default supports 2 arguments for metadata, `--include` and `--exclude`

These will resolve to an array of tags that will filter the tests cases

The default harness will process a tags argument on the test definition for this purpose

```ruby
class Test
  include Theorem::Hypothesis
  
  test 'test with metadata', tags: %w[important metadata]do
    #...
  end
  
  test 'test with regular metadata', tags: %w[metadata] do
    #...
  end
end
```

We can run `theorize --include important` to filter the available test cases this way, but this is a default implementation detail.

You can process tags and additional metadata however you want by writing a harness.

Note: The cli also supports a `--meta` flag to pass an arbitrary string to the harness
