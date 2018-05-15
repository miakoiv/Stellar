class AddExternalNameToProperties < ActiveRecord::Migration
  def change
    add_column :properties, :external_name, :string, after: :name
  end
end
