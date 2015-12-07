class AddSearchTagsToProducts < ActiveRecord::Migration
  def change
    add_column :products, :search_tags, :text, after: :memo
  end
end
