class AddCompoundToProducts < ActiveRecord::Migration
  def change
    add_column :products, :compound, :boolean, null: false, default: false, after: :live
  end
end
