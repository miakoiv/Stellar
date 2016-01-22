class AddPricingFactorToUsers < ActiveRecord::Migration
  def change
    add_column :users, :pricing_factor, :decimal, precision: 6, scale: 2, after: :guest, null: false, default: 1.0
  end
end
