class AddLocaleToUsers < ActiveRecord::Migration
  def change
    add_column :users, :locale, :string, after: :phone
  end
end
