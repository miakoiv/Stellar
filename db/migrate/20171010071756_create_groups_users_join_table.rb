class CreateGroupsUsersJoinTable < ActiveRecord::Migration
  def up
    create_join_table :groups, :users do |t|
      t.index :group_id
      t.index :user_id
    end

    # All existing users need a group assignment according to
    # their current user level. Groups that don't exist are created.
    Store.all.each do |store|
      l = store.locale
      if store.users.guest.any?
        guests = store.groups.where(
          name: ['Guest', 'Vieras']
        ).first_or_create(
          name: User.human_attribute_value(:level, :guest, locale: l),
          price_base: 1
        )
        store.users.guest.find_each(batch_size: 100) do |guest|
          guest.groups << guests
        end
      end
      if store.users.customer.any?
        customers = store.groups.where(
          name: ['Customer', 'Asiakas']
        ).first_or_create(
          name: User.human_attribute_value(:level, :customer, locale: l),
          price_base: 1
        )
        store.users.customer.each do |customer|
          customer.groups << customers
        end
      end
      if store.users.reseller.any?
        resellers = store.groups.where(
          name: ['Reseller', 'Jälleenmyyjä']
        ).first_or_create(
          name: User.human_attribute_value(:level, :reseller, locale: l),
          price_base: 2
        )
        store.users.reseller.each do |reseller|
          reseller.groups << resellers
        end
      end
      if store.users.manufacturer.any?
        manufacturers = store.groups.where(
          name: ['Manufacturer', 'Valmistaja']
        ).first_or_create(
          name: User.human_attribute_value(:level, :manufacturer, locale: l),
          price_base: 3
        )
        store.users.manufacturer.each do |manufacturer|
          manufacturer.groups << manufacturers
        end
      end
    end
  end

  def down
    drop_join_table :groups, :users
  end
end
