class AddAdditionalInfoPromptToProducts < ActiveRecord::Migration
  def change
    add_column :products, :additional_info_prompt, :string, after: :lead_time
  end
end
