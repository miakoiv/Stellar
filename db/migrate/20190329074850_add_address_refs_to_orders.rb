class AddAddressRefsToOrders < ActiveRecord::Migration[5.2]
  def up
    add_reference :orders, :billing_address, type: :integer, after: :order_type_id
    add_reference :orders, :shipping_address, type: :integer, after: :billing_address_id

    Order.find_each(batch_size: 50) do |order|
      billing_name         = order.customer_name
      billing_phone        = order.customer_phone
      billing_street       = order.billing_street
      billing_postalcode   = order.billing_postalcode
      billing_city         = order.billing_city
      billing_country_code = order.billing_country_code
      if billing_street.present? || billing_postalcode.present? || billing_city.present?
        billing_address = Address.find_or_initialize_by(
          name: billing_name || '',
          phone: billing_phone || '',
          company: '',
          address1: billing_street || '',
          address2: '',
          postalcode: billing_postalcode || '',
          city: billing_city || '',
          country_code: billing_country_code
        )
        order.update_columns(billing_address_id: billing_address.id)
      end
      shipping_name         = order.contact_person
      shipping_phone        = order.contact_phone
      shipping_company      = order.company_name
      shipping_street       = order.shipping_street
      shipping_postalcode   = order.shipping_postalcode
      shipping_city         = order.shipping_city
      shipping_country_code = order.shipping_country_code
      if shipping_name.present? || shipping_company.present? || shipping_street.present? || shipping_postalcode.present? || shipping_city.present?
        shipping_address = Address.find_or_initialize_by(
          name: shipping_name || '',
          phone: shipping_phone || '',
          company: shipping_company || '',
          address1: shipping_street || '',
          address2: '',
          postalcode: shipping_postalcode || '',
          city: shipping_city || '',
          country_code: shipping_country_code
        )
        order.update_columns(shipping_address_id: shipping_address.id)
      end
    end
  end

  def down
    remove_reference :orders, :billing_address
    remove_reference :orders, :shipping_address
  end
end
