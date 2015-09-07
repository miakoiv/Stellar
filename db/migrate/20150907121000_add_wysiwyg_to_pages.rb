class AddWysiwygToPages < ActiveRecord::Migration
  def change
    add_column :pages, :wysiwyg, :boolean, default: true, after: :content
  end
end
