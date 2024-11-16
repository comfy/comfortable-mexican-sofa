class AddMarkdownToComfyCmsSnippets < ActiveRecord::Migration[7.2]
  def change
    add_column :comfy_cms_snippets, :markdown, :boolean, default: false
  end
end
