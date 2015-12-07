class AddSearchTagsToProducts < ActiveRecord::Migration
  def change
    add_column :products, :search_tags, :text, after: :memo
    add_index :products, :search_tags, type: :fulltext
    add_index :products, :title
    add_index :products, :subtitle
  end
end
