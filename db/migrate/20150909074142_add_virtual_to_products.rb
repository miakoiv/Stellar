class AddVirtualToProducts < ActiveRecord::Migration
  def change
    add_column :products, :virtual, :boolean,
      null: false, default: false, after: :category_id
  end
end
