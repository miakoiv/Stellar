class AddThemeToStores < ActiveRecord::Migration
  def change
    add_column :stores, :theme, :string, after: :settings
    Store.reset_column_information
    Store.all.each do |store|
      store.update_columns theme: store.theme
    end
  end
end
