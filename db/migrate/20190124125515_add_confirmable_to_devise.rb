class AddConfirmableToDevise < ActiveRecord::Migration
  def up
    add_column :users, :confirmation_token, :string, after: :encrypted_password
    add_column :users, :confirmed_at, :datetime, after: :confirmation_token
    add_column :users, :confirmation_sent_at, :datetime, after: :confirmed_at
    add_index :users, :confirmation_token, unique: true

    User.where(approved: true).find_each(batch_size: 25) do |user|
      user.update confirmed_at: user.created_at
    end
  end

  def down
    remove_columns :users, :confirmation_token, :confirmed_at, :confirmation_sent_at
  end
end
