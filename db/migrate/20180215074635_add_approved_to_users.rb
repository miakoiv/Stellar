class AddApprovedToUsers < ActiveRecord::Migration
  def up
    add_column :users, :approved, :boolean, null: false, default: false, index: true, after: :last_sign_in_ip

    except_ids = Store.pluck(:default_group_id)
    UserSearch.new(except_group: except_ids).results.distinct.each do |user|
      user.update_columns approved: true
    end
  end

  def down
    remove_column :users, :approved
  end
end
