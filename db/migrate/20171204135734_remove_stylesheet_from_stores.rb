class RemoveStylesheetFromStores < ActiveRecord::Migration
  def up
    remove_attachment :stores, :stylesheet
  end

  def down
    add_attachment :stores, :stylesheet, after: :styles
  end
end
