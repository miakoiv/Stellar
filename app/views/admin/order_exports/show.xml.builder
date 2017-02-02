xml.instruct!
xml.order do
  xml.storeNumber @order.store.erp_number
  xml.customerReference @order.our_reference
  xml.ourReference @order.external_identifier
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
        xml.unitPrice item.price_for_export
        xml.subTotal item.subtotal_for_export
        xml.shippingDate @order.shipping_at
      end
    end
  end

  xml.grandTotal @order.grand_total_for_export
end
