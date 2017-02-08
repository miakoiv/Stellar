#encoding: utf-8

class Section < ActiveRecord::Base

  belongs_to :page

  enum purpose: {text: 1, product: 2, promotion: 3}
end
