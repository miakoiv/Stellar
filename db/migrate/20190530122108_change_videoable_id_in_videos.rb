class ChangeVideoableIdInVideos < ActiveRecord::Migration[5.2]
  def up
    change_column :videos, :videoable_id, :integer
  end

  def down
    change_column :videos, :videoable_id, :bigint
  end
end
