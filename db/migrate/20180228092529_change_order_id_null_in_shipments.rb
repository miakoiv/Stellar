class ChangeOrderIdNullInShipments < ActiveRecord::Migration
  def change
    change_column_null :shipments, :order_id, true
  end
end
