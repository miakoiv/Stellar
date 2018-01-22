class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.references :documentable, polymorphic: true, index: true
      t.integer :priority, null: false, default: 0

      t.timestamps null: false
    end
  end
end
