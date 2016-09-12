class ChangeOrderTypeAssociation < ActiveRecord::Migration
  def up
    add_reference :order_types, :store, index: true, foreign_key: false, after: :id
    remove_column :order_types, :inventory_id
  end

  def down
    add_reference :order_types, :inventory, index: true, foreign_key: false, after: :id
    remove_column :order_types, :store_id
  end
end
