class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.belongs_to :store, null: false, index: true
      t.belongs_to :parent_page, index: true
      t.string :title
      t.text :content

      t.integer :priority
      t.timestamps null: false
    end
  end
end
