class AddSettingsToStores < ActiveRecord::Migration
  def change
    add_column :stores, :settings, :text, after: :tracking_code
  end
end
