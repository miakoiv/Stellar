class ChangeDescriptionToStringInPromotionHandlers < ActiveRecord::Migration
  def change
    change_column :promotion_handlers, :description, :string
  end
end
