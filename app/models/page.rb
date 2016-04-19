#encoding: utf-8

class Page < ActiveRecord::Base

  resourcify
  include Authority::Abilities
  include Imageable
  include Reorderable
  include FriendlyId
  friendly_id :title, use: [:slugged, :history]

  #---
  # Pages serve different purposes while they are essentially comprised of
  # the same attributes. Route pages use their slug for routing to /front
  # or /cart. Primary and secondary pages are regular user edited content,
  # while secondaries don't get a navbar item. Banners and templates are
  # used for content generation.
  enum purpose: {route: 0, primary: 1, secondary: 2, banner: 3, template: 4}

  #---
  belongs_to :store
  belongs_to :parent_page, class_name: 'Page'
  has_many :sub_pages, class_name: 'Page', foreign_key: :parent_page_id
  has_and_belongs_to_many :albums

  # Acceptable parent pages are regular top level pages.
  scope :acceptable_parent, -> { where(parent_page_id: nil).where(purpose: [1, 2]) }

  # Navbar items are created from route and primary pages.
  scope :navbar, -> { where(parent_page_id: nil).where(purpose: [0, 1]) }

  # Footer gets the secondary pages.
  scope :footer, -> { where(purpose: 2) }

  #---
  validates :title, presence: true

  #---
  def self.purpose_options
    purposes.keys.map { |p| [Page.human_attribute_value(:purpose, p), p] }
  end

  #---
  def can_be_nested?
    primary? || secondary?
  end

  def can_have_albums?
    primary? || secondary?
  end

  def needs_content?
    !route?
  end

  # Prevent FriendlyId from changing slugs on route pages.
  def should_generate_new_friendly_id?
    !route? && title_changed? || super
  end

  def to_s
    title
  end

  def description
    content
  end
end
