class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.belongs_to :store, null: false, index: true
      t.belongs_to :user, null: false, index: true
      t.string :action
      t.belongs_to :resource, polymorphic: true, null: false
      t.belongs_to :context, polymorphic: true, null: false, index: true
      t.text :differences

      t.timestamps null: false
    end
  end
end
