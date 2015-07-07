#encoding: utf-8

class Relationship < ActiveRecord::Base

  # We connect a product to its parent by product codes.
  # Since this is a generic relationship with no respect for store scopes,
  # the product model must specify a join to the products table in its
  # has_many relation to apply necessary scopes.
  belongs_to :parent, class_name: 'Product', foreign_key: :parent_code, primary_key: :code
  belongs_to :product, foreign_key: :product_code, primary_key: :code

end
