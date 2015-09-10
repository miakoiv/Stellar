#encoding: utf-8

class Store < ActiveRecord::Base

  resourcify
  include Authority::Abilities
  include Imageable

  #---
  after_create :assign_slug

  #---
  belongs_to :contact_person, class_name: 'User'
  has_many :categories
  has_many :products
  has_many :custom_attributes
  has_many :orders
  has_many :users
  has_many :pages
  has_and_belongs_to_many :inventories
  has_many :order_types, through: :inventories
  belongs_to :shipping_cost_product, class_name: 'Product'

  scope :all_except, -> (this) { where.not(id: this) }

  #---
  validates :name, presence: true
  validates :erp_number, numericality: true, allow_blank: true

  #---
  # Performs an inventory valuation of items in the shipping inventory.
  def inventory_valuation
    items = inventory_for(:shipping).inventory_items
              .for_products(products.categorized)
    [items, items.map { |item| item.total_value }.sum]
  end

  # Make shipping the default order type.
  def default_order_type
    order_types.find_by(has_shipping: true)
  end

  # Finds the first inventory by purpose.
  def inventory_for(purpose)
    inventories.by_purpose(purpose)
  end

  def category_options
    categories.map { |c| [c.name, c.id] }
  end

  def order_type_options
    order_types.map { |o| [o.to_s, o.id] }
  end

  def user_options
    users.map { |u| [u.to_s, u.id] }
  end

  def page_options
    pages.map { |p| [p.to_s, p.id] }
  end

  # All custom values available to the store, grouped by custom attribute id.
  def grouped_custom_values
    custom_attributes.map do |a|
      [a.id, a.custom_values.map { |v| {id: v.id, value: v.to_s} }]
    end
  end

  # How to title the store in navigation menus.
  # The given string undergoes I18n before output.
  def menu_title
    self[:menu_title] || 'store'
  end

  def to_s
    name
  end

  private
    def assign_slug
      taken_slugs = Store.all_except(self).map(&:slug)
      len = 3
      unique_slug = "#{name}#{id}#{Time.now.to_i}"
        .parameterize.underscore.mb_chars.downcase
      begin
        slug = unique_slug[0, len]
        len += 1
      end while taken_slugs.include?(slug)
      update_attributes(slug: slug)
    end
end
