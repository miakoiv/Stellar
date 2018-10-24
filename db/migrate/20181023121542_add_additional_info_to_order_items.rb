class AddAdditionalInfoToOrderItems < ActiveRecord::Migration
  def change
    add_column :order_items, :additional_info, :string, after: :label
  end
end
