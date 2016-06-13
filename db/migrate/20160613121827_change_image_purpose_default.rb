class ChangeImagePurposeDefault < ActiveRecord::Migration
  def up
    change_column_default :images, :purpose, nil
  end
  def down
    change_column_default :images, :purpose, 0
  end
end
