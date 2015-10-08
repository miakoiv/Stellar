class CreateIframes < ActiveRecord::Migration
  def change
    create_table :iframes do |t|
      t.belongs_to :product, index: true
      t.text :html

      t.integer :priority
      t.timestamps null: false
    end
  end
end
