#encoding: utf-8

class Store < ActiveRecord::Base

  resourcify
  include Authority::Abilities
  include Imageable

  after_create :assign_slug

  belongs_to :contact_person, class_name: 'User'
  has_many :categories
  has_many :products
  has_many :custom_attributes
  has_many :orders
  has_many :users
  has_many :pages
  has_many :inventories
  def inventories
    local_inventory? ? super : Inventory.global
  end

  scope :all_except, -> (this) { where.not(id: this) }

  validates :name, presence: true
  validates :erp_number, numericality: true, allow_blank: true


  # Make shipping the default order type. We can't have order_types through
  # inventories because some stores use global inventories.
  def default_order_type
    inventories.map(&:order_types).flatten.find { |o| o.has_shipping? }
  end

  # Performs a stock lookup on a product. Returns a hash
  # of inventory items keyed by inventory purpose, adjusted by orders.
  def stock_lookup(code)
    stock = ActiveSupport::HashWithIndifferentAccess.new.tap do |stock|
      inventories.each do |inventory|
        if (item = inventory.lookup(code))
          stock[inventory.purpose] = OrderItem.adjust!(item)
        end
      end
    end
  end

  # Performs an inventory valuation on given products recursively.
  # Returns a [inventory, grand_total] tuple, where inventory is a hash
  # keyed by product, containing [stock, inventory_valuation] tuples.
  # stock is an inventory item from stock_lookup, inventory_valuation
  # is another inventory valuation tuple performed on the components
  # of the product.
  def inventory_valuation(products)
    grand_total = 0
    inventory = {}.tap do |inventory|
      products.each do |product|
        stock = stock_lookup(product.code)
        grand_total += stock[:shipping].try(:total_value) || 0
        inventory[product] = [stock, inventory_valuation(product.components)]
      end
    end
    [inventory, grand_total]
  end

  # Finds the first inventory by purpose.
  def inventory_for(purpose)
    inventories.by_purpose(purpose)
  end

  def category_options
    categories.map { |c| [c.name, c.id] }
  end

  def order_types
    inventories.map(&:order_types).flatten
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
