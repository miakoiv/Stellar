class DropCustomValues < ActiveRecord::Migration
  def up
    drop_table :custom_values
  end

  def down
    create_table :custom_values do |t|
      t.belongs_to :custom_attribute, null: false, index: true
      t.string :value

      t.integer :priority
      t.timestamps null: false
    end
  end
end
