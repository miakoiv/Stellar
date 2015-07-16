class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.belongs_to :store, null: false, index: true, foreign_key: true
      t.belongs_to :parent_page, index: true, foreign_key: true
      t.string :title
      t.text :content

      t.integer :priority
      t.timestamps null: false
    end
  end
end
