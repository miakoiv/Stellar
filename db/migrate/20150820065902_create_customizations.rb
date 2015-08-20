class CreateCustomizations < ActiveRecord::Migration
  def change
    create_table :customizations do |t|
      t.belongs_to :customizable, polymorphic: true, index: true
      t.belongs_to :custom_attribute, index: true
      t.belongs_to :custom_value, index: true

      t.timestamps null: false
    end
  end
end
