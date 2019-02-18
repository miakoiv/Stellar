class Tag < ApplicationRecord

  resourcify
  include Authority::Abilities
  include Pictureable
  include FriendlyId
  friendly_id :slugger, use: [:slugged, :scoped], scope: :store

  APPEARANCES = [
    :default, :primary, :success, :info, :warning, :danger
  ].freeze

  #---
  belongs_to :store
  has_and_belongs_to_many :products

  default_scope { order(:name) }
  scope :searchable, -> { where(searchable: true) }
  scope :graphic, -> { joins(:pictures) }

  #---
  validates :name, presence: true, uniqueness: {scope: :store}
  after_save :touch_products

  #---
  def self.appearance_options
    APPEARANCES.map { |a| [human_attribute_value(:appearance, a), a, data: {appearance: a}.to_json] }
  end

  #---
  def slugger
    [:name, [:name, :id]]
  end

  def should_generate_new_friendly_id?
    will_save_change_to_name? || super
  end

  def description
    name
  end

  def to_s
    name
  end

  private
    def touch_products
      products.each(&:touch)
    end
end
