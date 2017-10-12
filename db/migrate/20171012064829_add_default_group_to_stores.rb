class AddDefaultGroupToStores < ActiveRecord::Migration
  def up
    add_reference :stores, :default_group, null: false, after: :slug

    Store.all.each do |store|
      store.update default_group_id: store.groups.retail.first.id
    end
  end

  def down
    remove_reference :stores, :default_group
  end
end
