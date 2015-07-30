class AddHostToStores < ActiveRecord::Migration
  def change
    add_column :stores, :host, :string, after: :contact_person_id
  end
end
