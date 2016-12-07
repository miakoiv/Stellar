class AddHasInstallationToOrderTypes < ActiveRecord::Migration
  def change
    add_column :order_types, :has_installation, :boolean, null: false, default: false, after: :has_shipping
  end
end
