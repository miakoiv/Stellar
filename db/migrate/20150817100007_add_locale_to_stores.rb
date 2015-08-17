class AddLocaleToStores < ActiveRecord::Migration
  def change
    add_column :stores, :locale, :string, null: false, default: 'fi',
      after: :theme
  end
end
