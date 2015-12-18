class AddLiveToProducts < ActiveRecord::Migration
  def change
    add_column :products, :live, :boolean, null: false, default: false, index: true, after: :store_id
  end
end
