class ChangeLeadTimeTypeInProducts < ActiveRecord::Migration
  def up
    change_column :products, :lead_time, :string

    Store.all.each do |store|
      lead_time_unit = {'en' => 'days', 'fi' => 'päivää'}[store.locale]
      store.products.find_each(batch_size: 50) do |product|
        next unless product.lead_time.present?
        product.update_columns lead_time: "#{product.lead_time} #{lead_time_unit}"
      end
    end
  end

  def down
    change_column :products, :lead_time, :integer
  end
end
