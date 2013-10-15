class Create<%= class_name.pluralize %> < ActiveRecord::Migration

  def change
    create_table :<%= file_name.pluralize %> do |t|
    <%- model_attrs.each do |attr| -%>
      t.<%= attr.type %> :<%= attr.name %>
    <%- end -%>
      t.timestamps
    end
  end

end