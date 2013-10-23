require_relative '../test_helper'

class <%= class_name %>Test < ActiveSupport::TestCase

  def test_fixtures_validity
    <%= class_name %>.all.each do |<%= file_name %>|
      assert <%= file_name %>.valid?, <%= file_name %>.errors.inspect
    end
  end

  def test_validation
    <%= file_name %> = <%= class_name %>.new
    assert <%= file_name %>.invalid?
    assert_errors_on <%= file_name %>, <%= model_attrs.collect{|attr| ":#{attr.name}"}.join(', ') %>
  end

  def test_creation
    assert_difference '<%= class_name %>.count' do
      <%= class_name %>.create(
      <%- model_attrs.each do |attr| -%>
        :<%= attr.name %> => 'test <%= attr.name %>',
      <%- end -%>
      )
    end
  end

end