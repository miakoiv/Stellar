class AddLetterheadToStores < ActiveRecord::Migration
  def change
    add_column :stores, :letterhead, :text, after: :settings
  end
end
