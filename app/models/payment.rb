#encoding: utf-8

class Payment < ActiveRecord::Base

  monetize :amount

  #---
  belongs_to :order

  default_scope { order(created_at: :desc) }

end
