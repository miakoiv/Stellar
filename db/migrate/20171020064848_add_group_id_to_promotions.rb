class AddGroupIdToPromotions < ActiveRecord::Migration
  def change
    add_reference :promotions, :group, index: true, null: false, after: :store_id
  end
end
