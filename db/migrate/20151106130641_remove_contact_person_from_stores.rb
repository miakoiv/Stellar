class RemoveContactPersonFromStores < ActiveRecord::Migration
  def change
    remove_reference :stores, :contact_person, index: true
  end
end
