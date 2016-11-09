class RemoveDefaultCountryInOrders < ActiveRecord::Migration
  def up
    change_column_null :orders, :billing_country, true
    change_column_null :orders, :shipping_country, true
    change_column_default :orders, :billing_country, nil
    change_column_default :orders, :shipping_country, nil
  end

  def down
    change_column_null :orders, :billing_country, false, 'FI'
    change_column_null :orders, :shipping_country, false, 'FI'
    change_column_default :orders, :billing_country, 'FI'
    change_column_default :orders, :shipping_country, 'FI'
  end
end
