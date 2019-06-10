class CreateProductUploads < ActiveRecord::Migration[5.2]
  def change
    create_table :product_uploads do |t|
      t.belongs_to :store, type: :integer, null: false, index: true
      t.attachment :attachment
      t.datetime :processed_at

      t.timestamps
    end
  end
end
