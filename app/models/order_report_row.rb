#encoding: utf-8
#
# OrderReportRows aggregate data from concluded orders to facilitate
# report generation. They are created or updated automatically when
# orders are concluded, or can be recreated via a rake task.
#
class OrderReportRow < ActiveRecord::Base

  monetize :total_value_cents, disable_validation: true

  #---
  belongs_to :order_type
  belongs_to :user
  belongs_to :shipping_country, class_name: 'Country', foreign_key: :shipping_country_code
  belongs_to :product

  #---
  def self.from_order_and_item(order, order_item)
    report_row = where(
      order_type: order.order_type,
      user: order.user,
      shipping_country_code: order.shipping_country_code,
      product: order_item.product,
      ordered_at: order.completed_at.to_date
    ).first_or_initialize do |row|
      row.amount = 0
      row.total_value_cents = 0
    end
    report_row.amount += order_item.amount
    report_row.total_value_cents += order_item.grand_total_sans_tax_cents
    report_row.save
  end
end
