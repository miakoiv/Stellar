xml.order do
  xml.customerReference @order.our_reference
  xml.ourReference @order.your_reference
  xml.message @order.message

  xml.orderDate @order.completed_at.to_date
  xml.shippingDate @order.shipping_at

  xml.customer do
    xml.name @order.customer_name
    xml.company @order.company_name
    xml.contactPerson @order.contact_person

    xml.billing do
      xml.address @order.billing_address
      xml.postalcode @order.billing_postalcode
      xml.city @order.billing_city
      xml.country @order.billing_country_code
      xml.vatNumber @order.vat_number
    end

    xml.shipping do
      xml.address @order.shipping_address
      xml.postalcode @order.shipping_postalcode
      xml.city @order.shipping_city
      xml.country @order.shipping_country_code
    end
  end

  xml.notes @order.notes

  xml.order_items do
    @order.order_items.each do |item|
      xml.item do
        xml.productCode item.product_code
        xml.title item.product_title
        xml.subtitle item.product_subtitle
        xml.amount item.amount
        xml.unitPrice item.includes_tax? ? item.price_with_tax : item.price_sans_tax
        xml.subTotal item.includes_tax? ? item.subtotal_with_tax : item.subtotal_sans_tax
        xml.shippingDate @order.shipping_at
      end
    end
  end

  xml.grandTotal @order.includes_tax? ? @order.grand_total_with_tax : @order.grand_total_sans_tax
end
