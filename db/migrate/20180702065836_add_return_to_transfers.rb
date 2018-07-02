class AddReturnToTransfers < ActiveRecord::Migration
  def change
    add_column :transfers, :return, :boolean, null: false, default: false, after: :destination_id
  end
end
