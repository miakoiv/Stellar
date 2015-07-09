#encoding: utf-8

class Store < ActiveRecord::Base

  resourcify
  include Authority::Abilities
  include Imageable

  after_create :assign_slug

  has_many :categories
  has_many :products
  has_many :orders
  has_many :users

  scope :all_except, -> (this) { where.not(id: this) }

  validates :name, presence: true
  validates :erp_number, numericality: true, allow_blank: true


  def category_options
    categories.map { |c| [c.name, c.id] }
  end

  def user_options
    users.map { |u| [u.to_s, u.id] }
  end

  def to_s
    new_record? ? 'New store' : name
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
