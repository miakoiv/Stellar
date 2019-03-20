class CreateMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :messages do |t|
      t.belongs_to :store, type: :integer, null: false, index: true
      t.belongs_to :context, polymorphic: true, null: false, index: true
      t.string :stage, null: false
      t.boolean :disabled, null: false, default: false
      t.text :content

      t.timestamps
    end
  end
end
