class AddAvailableAtDeletedAtToProducts < ActiveRecord::Migration
  def change
    add_column :products, :available_at, :date, after: :priority
    add_column :products, :deleted_at, :date, after: :available_at
  end
end
