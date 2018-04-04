class AddNameToSections < ActiveRecord::Migration
  def change
    add_column :sections, :name, :string, after: :page_id
  end
end
