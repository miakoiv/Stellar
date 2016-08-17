class AddShippingNotesToProducts < ActiveRecord::Migration
  def change
    add_column :products, :shipping_notes, :text, after: :lead_time
  end
end
