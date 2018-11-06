class AddActivationCodeToPromotions < ActiveRecord::Migration
  def change
    add_column :promotions, :activation_code, :string, after: :last_date
  end
end
