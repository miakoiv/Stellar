class RemoveDeprecatedFieldsFromProducts < ActiveRecord::Migration
  def change
    remove_column :products, :compound, :boolean, null: false, default: false, after: :live
    remove_column :products, :virtual, :boolean, null: false, default: false, after: :compound
  end
end
