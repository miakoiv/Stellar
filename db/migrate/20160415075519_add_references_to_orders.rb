class AddReferencesToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :external_number, :string, after: :number
    add_column :orders, :your_reference, :string, after: :external_number
    add_column :orders, :our_reference, :string, after: :your_reference
    add_column :orders, :message, :string, after: :our_reference
  end
end
