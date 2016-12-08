class CreateHostnames < ActiveRecord::Migration
  def change
    create_table :hostnames do |t|
      t.references :resource, polymorphic: true, index: true
      t.string :fqdn, null: false, index: true
      t.boolean :portal, null: false, default: false

      t.timestamps null: false
    end
  end
end
