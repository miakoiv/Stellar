class AddStylesheetToStyles < ActiveRecord::Migration
  def up
    add_attachment :styles, :stylesheet, after: :store_id
  end

  def down
    remove_attachment :styles, :stylesheet
  end
end
