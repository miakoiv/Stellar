class MergeUsersAcrossStores < ActiveRecord::Migration
  def up
    User.unscoped.group(:email).count.select { |_, n| n > 1 }.each do |email, n|
      puts "Merging #{n} instances of #{email}"
      users = User.reorder(:id).where(email: email)
      master = users.first
      merged = users.where.not(id: master)
      merged.each do |mrg|
        master.groups << mrg.groups
        mrg.roles.each do |role|
          master.grant(role.name, role.resource) unless master.has_role?(role.name, role.resource)
        end
        mrg.orders.update_all user_id: master.id
        mrg.customer_assets.update_all user_id: master.id
        mrg.destroy
      end
    end
  end

  def down
  end
end
