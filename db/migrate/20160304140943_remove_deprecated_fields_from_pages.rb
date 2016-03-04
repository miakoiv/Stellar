class RemoveDeprecatedFieldsFromPages < ActiveRecord::Migration
  def up
    remove_column :pages, :navbar
    remove_column :pages, :internal
    remove_column :pages, :letterhead
  end

  def down
    add_column :pages, :navbar, :boolean, null: false, default: false, after: :parent_page_id
    add_column :pages, :internal, :boolean, null: false, default: false, after: :content
    add_column :pages, :letterhead, :boolean, null: false, default: false, after: :content
  end
end
