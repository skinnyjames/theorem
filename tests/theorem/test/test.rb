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
    expect(@after_all).to eql(nil)
  end

  test 'asserts before_all' do
    expect(@before_all).to be(true)
    expect(@before_each).to be(true)

    @before_each = :mutated
    @before_all = :mutated

    @after_each = true
    @after_all = true
    @browser = :foobar
  end

  test 'asserts mutations in hooks' do
    expect(@before_all).to eql(true) # before all leaks state into the cases
    expect(@before_each).to be(true) # before each does not
    expect(@browser).to be(nil)
    expect(@after_all).to be(nil)
    expect(@after_each).to be(nil)
    @after_each = true
  end
end