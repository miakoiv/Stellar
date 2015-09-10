class AddTrackingCodeToStores < ActiveRecord::Migration
  def change
    add_column :stores, :tracking_code, :string, after: :free_shipping_at
  end
end
