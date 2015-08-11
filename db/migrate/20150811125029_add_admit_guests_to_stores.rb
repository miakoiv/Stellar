class AddAdmitGuestsToStores < ActiveRecord::Migration
  def change
    add_column :stores, :admit_guests, :boolean,
      null: false, default: false, after: :theme
  end
end
