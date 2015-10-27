class AddAttributeTypeToCustomAttributes < ActiveRecord::Migration
  def change
    add_column :custom_attributes, :attribute_type, :integer, null: false, default: 0, after: :store_id
  end
end
