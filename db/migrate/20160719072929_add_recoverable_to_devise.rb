class AddRecoverableToDevise < ActiveRecord::Migration
  def up
    ## Recoverable
    # t.string   :reset_password_token
    # t.datetime :reset_password_sent_at
    # add_index :users, :reset_password_token, unique: true

    add_column :users, :reset_password_token, :string, after: :encrypted_password
    add_column :users, :reset_password_sent_at, :datetime, after: :reset_password_token
    add_index :users, :reset_password_token, unique: true
  end

  def down
    remove_columns :users, :reset_password_token, :reset_password_sent_at
  end
end
