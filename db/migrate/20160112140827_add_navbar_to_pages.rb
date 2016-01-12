class AddNavbarToPages < ActiveRecord::Migration
  def change
    add_column :pages, :navbar, :boolean, null: false, default: false, index: true, after: :parent_page_id
  end
end
