class AddLabelToOrderItems < ActiveRecord::Migration
  def change
    add_column :order_items, :label, :string, after: :product_id
  end
end
