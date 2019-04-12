#
# OrderReportRows aggregate data from concluded orders to facilitate
# report generation. They are created or updated automatically when
# orders are concluded, or can be recreated via a rake task.
#
class OrderReportRow < ApplicationRecord

  monetize :total_sans_tax_cents, disable_validation: true
  monetize :total_with_tax_cents, disable_validation: true
  monetize :total_tax_cents, disable_validation: true

  #---
  belongs_to :group
  belongs_to :order_type
  belongs_to :product
  belongs_to :user, optional: true
  belongs_to :store_portal, class_name: 'Store', optional: true
  belongs_to :shipping_country, class_name: 'Country', foreign_key: :shipping_country_code

  #---
  def self.update_row_for(order, order_item, options = {})
    factor = options[:factor]
    product = order_item.product
    return false unless product.present?
    row = where(
      group: options[:group],
      user: options[:user],
      order_type: order.order_type,
      store_portal: order.store_portal,
      shipping_country_code: order.shipping_address&.country_code,
      product: product,
      tax_rate: order_item.tax_rate,
      ordered_at: order.completed_at.to_date
    ).first_or_initialize
    row.amount += factor * order_item.amount
    row.total_sans_tax_cents += factor * order_item.grand_total_sans_tax.cents
    row.total_with_tax_cents += factor * order_item.grand_total_with_tax.cents
    row.total_tax_cents += factor * order_item.tax_total.cents
    row.save
  end

  def self.create_from(order)
    options = order.report_options.merge(factor: 1)
    transaction do
      order.order_items.each do |order_item|
        update_row_for(order, order_item, options)
      end
    end
  end

  # Reporting a cancelled order is done by creating report rows
  # with a factor of minus one to cancel the earlier entries.
  def self.cancel_entries_from(order)
    options = order.report_options.merge(factor: -1)
    transaction do
      order.order_items.each do |order_item|
        update_row_for(order, order_item, options)
      end
    end
  end
end
