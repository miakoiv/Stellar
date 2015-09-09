class AddB2BSalesToStores < ActiveRecord::Migration
  def change
    add_column :stores, :b2b_sales, :boolean,
      null: false, default: false, after: :locale
  end
end
