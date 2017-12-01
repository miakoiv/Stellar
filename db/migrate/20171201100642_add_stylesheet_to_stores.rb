class AddStylesheetToStores < ActiveRecord::Migration
  def up
    add_attachment :stores, :stylesheet, after: :styles
  end

  def down
    remove_attachment :stores, :stylesheet
  end
end
