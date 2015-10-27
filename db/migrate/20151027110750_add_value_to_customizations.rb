class AddValueToCustomizations < ActiveRecord::Migration
  def change
    add_column :customizations, :value, :string, after: :custom_value_id
  end
end
