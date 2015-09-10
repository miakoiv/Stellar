class AddMenuTitleToStores < ActiveRecord::Migration
  def change
    add_column :stores, :menu_title, :string, after: :host
  end
end
