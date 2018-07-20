class RemovePurposePriorityFromImages < ActiveRecord::Migration
  def change
    remove_column :images, :purpose, :integer, null: false, after: :imageable_type
    remove_column :images, :priority, :integer, null: false, default: 0, after: :attachment_fingerprint
  end
end
