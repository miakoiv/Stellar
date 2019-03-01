class DropIframes < ActiveRecord::Migration[5.2]
  def change
    drop_table :iframes do |t|
      t.belongs_to :product, index: true
      t.text :html
      t.integer :priority
    end
  end
end
