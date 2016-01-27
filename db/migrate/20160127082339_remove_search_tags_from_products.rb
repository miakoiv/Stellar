class RemoveSearchTagsFromProducts < ActiveRecord::Migration
  def change
    remove_index :products, :search_tags
    remove_column :products, :search_tags, :text, after: :memo
  end
end
