class AddStylesToStores < ActiveRecord::Migration
  def change
    add_column :stores, :styles, :text, after: :settings
  end
end
