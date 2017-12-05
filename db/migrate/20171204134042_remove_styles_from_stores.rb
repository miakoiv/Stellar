class RemoveStylesFromStores < ActiveRecord::Migration
  def change
    remove_column :stores, :styles, :text, after: :settings
  end
end
