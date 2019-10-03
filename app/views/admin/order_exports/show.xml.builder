xml.instruct!
xml.order do
  xml.orderNumber @order.number
  xml.storeNumber @order.store.erp_number
  xml.customerReference @order.our_reference
  xml.ourReference @order.external_identifier
  xml.message @order.message

  xml.orderDate @order.completed_at.to_date
  xml.shippingDate @order.shipping_at

  xml.customer do
    xml.company @order.shipping_address&.company
    xml.name @order.shipping_address&.name
    xml.contactPerson @order.shipping_address&.name

    xml.billing do
      xml.address @order.billing_address&.address1
      xml.postalcode @order.billing_address&.postalcode
      xml.city @order.billing_address&.city
      xml.country @order.billing_address&.country_code
      xml.vatNumber @order.vat_number
    end

    xml.shipping do
      xml.address @order.shipping_address&.address1
      xml.postalcode @order.shipping_address&.postalcode
      xml.city @order.shipping_address&.city
      xml.country @order.shipping_address&.country_code
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
