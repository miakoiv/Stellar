#encoding: utf-8

class Item < ActiveRecord::Base

  belongs_to :inventory
  belongs_to :product
end
