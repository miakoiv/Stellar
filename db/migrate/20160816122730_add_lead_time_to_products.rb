class AddLeadTimeToProducts < ActiveRecord::Migration
  def change
    add_column :products, :lead_time, :integer, after: :dimension_w
  end
end
