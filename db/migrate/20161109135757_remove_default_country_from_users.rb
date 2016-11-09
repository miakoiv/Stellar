class RemoveDefaultCountryFromUsers < ActiveRecord::Migration
  def up
    change_column_default :users, :billing_country, nil
    change_column_default :users, :shipping_country, nil
  end

  def down
    change_column_default :users, :billing_country, 'FI'
    change_column_default :users, :shipping_country, 'FI'
  end
end
