#encoding: utf-8

class Payment < ActiveRecord::Base

  monetize :amount_cents

  #---
  belongs_to :order

  default_scope { order(created_at: :desc) }

  #---
  def self.available_gateways
    %w{None Paybyway}
  end
end
