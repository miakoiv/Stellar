class CreateColumns < ActiveRecord::Migration
  def change
    create_table :columns do |t|
      t.belongs_to :section, null: false, index: true
      t.string :align, null: false, default: 'align-top'
      t.boolean :pivot, null: false, default: false

      t.integer :priority, null: false, default: 0
      t.timestamps null: false
    end
  end
end
