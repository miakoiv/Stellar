class AddPurposeToImages < ActiveRecord::Migration
  def change
    add_column :images, :purpose, :integer, null: false, default: 0, after: :image_type_id
  end
end
