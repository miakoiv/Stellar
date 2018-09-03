class RemoveImageableFromImages < ActiveRecord::Migration
  def change
    remove_column :images, :imageable_id, :integer, after: :store_id
    remove_column :images, :imageable_type, :string, after: :store_id
  end
end
