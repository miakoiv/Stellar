#encoding: utf-8

class CustomValue < ActiveRecord::Base

  include Reorderable

  #---
  belongs_to :custom_attribute

  #---
  def to_s
    value
  end

  def to_i
    value.to_i
  end
end
