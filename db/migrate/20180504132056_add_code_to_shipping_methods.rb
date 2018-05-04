class AddCodeToShippingMethods < ActiveRecord::Migration
  def change
    add_column :shipping_methods, :code, :string, after: :name
  end
end
