class AddSmtpSettingsToStores < ActiveRecord::Migration[5.2]
  def change
    add_column :stores, :smtp_settings, :text, after: :settings
  end
end
