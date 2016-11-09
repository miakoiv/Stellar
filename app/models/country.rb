#encoding: utf-8

class Country < ActiveRecord::Base

  self.primary_key = 'code'

  default_scope { order(:name) }

end
