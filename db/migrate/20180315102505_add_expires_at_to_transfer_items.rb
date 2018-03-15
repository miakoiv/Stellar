class AddExpiresAtToTransferItems < ActiveRecord::Migration
  def change
    add_column :transfer_items, :expires_at, :date, after: :lot_code
  end
end
