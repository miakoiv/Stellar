class AddPurposeToPages < ActiveRecord::Migration
  def change
    add_column :pages, :purpose, :integer, null: false, default: 1, after: :store_id
  end
end
