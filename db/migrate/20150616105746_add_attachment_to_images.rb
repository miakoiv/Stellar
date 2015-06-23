class AddAttachmentToImages < ActiveRecord::Migration
  def self.up
    change_table :images do |t|
      t.attachment :attachment
    end
  end

  def self.down
    remove_attachment :images, :attachment
  end
end
