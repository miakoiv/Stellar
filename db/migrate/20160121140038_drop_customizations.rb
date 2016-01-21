class DropCustomizations < ActiveRecord::Migration
  def up
    drop_table :customizations
  end

  def down
    create_table :customizations do |t|
      t.belongs_to :customizable, polymorphic: true, index: true
      t.belongs_to :custom_attribute, index: true
      t.belongs_to :custom_value, index: true
      t.string :value

      t.timestamps null: false
    end
  end
end
