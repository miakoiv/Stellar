class RemoveLetterheadFromStores < ActiveRecord::Migration
  def change
    remove_column :stores, :letterhead, :text
  end
end
