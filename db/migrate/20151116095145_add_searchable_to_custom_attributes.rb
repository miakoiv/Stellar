class AddSearchableToCustomAttributes < ActiveRecord::Migration
  def change
    add_column :custom_attributes, :searchable, :boolean, null: false, default: false, after: :unit_pricing
  end
end
