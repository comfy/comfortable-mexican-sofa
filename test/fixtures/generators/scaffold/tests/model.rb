require_relative '../test_helper'

class FooTest < ActiveSupport::TestCase

  def test_fixtures_validity
    Foo.all.each do |foo|
      assert foo.valid?, foo.errors.inspect
    end
  end

  def test_validation
    foo = Foo.new
    assert foo.invalid?
    assert_errors_on foo, :bar
  end

  def test_creation
    assert_difference 'Foo.count' do
      Foo.create(
        :bar => 'test bar',
      )
    end
  end

end