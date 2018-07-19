class AddStoreIdToImages < ActiveRecord::Migration
  def up
    add_column :images, :store_id, :integer, after: :id

    Image.find_each(batch_size: 50) do |image|
      image.update_columns store_id: image.calculated_store_id
    end
  end

  def down
    remove_column :images, :store_id, :integer
  end
end
