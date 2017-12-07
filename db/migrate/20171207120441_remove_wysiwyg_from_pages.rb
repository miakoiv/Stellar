class RemoveWysiwygFromPages < ActiveRecord::Migration
  def change
    remove_column :pages, :wysiwyg, :boolean, after: :content
  end
end
