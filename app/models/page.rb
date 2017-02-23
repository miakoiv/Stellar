#encoding: utf-8

class Page < ActiveRecord::Base

  resourcify
  include Authority::Abilities
  include Imageable
  include Reorderable
  include FriendlyId
  friendly_id :slugger, use: [:slugged, :history]

  #---
  enum purpose: {
    route: 0,     # navigation node routed to #slug
    primary: 1,   # primary content in main nav
    secondary: 2, # secondary content in footer
    banner: 3,    # banner container (deprecated)
    template: 4,  # printed page template
    category: 5,  # navigation node to linked category (or categories root)
    empty: 6,     # empty page providing a navigation node
  }

  #---
  belongs_to :store
  belongs_to :parent_page, class_name: 'Page'
  has_many :sub_pages, class_name: 'Page', foreign_key: :parent_page_id
  has_and_belongs_to_many :albums

  default_scope { sorted }

  # Acceptable parent pages are regular top level pages.
  scope :acceptable_parent, -> { where(parent_page_id: nil).where(purpose: [1, 2]) }

  # Navbar items are created from route and primary pages.
  scope :navbar, -> { where(parent_page_id: nil).where(purpose: [0, 1]) }

  # Footer gets the secondary pages.
  scope :footer, -> { where(parent_page_id: nil).secondary }

  #---
  validates :title, presence: true

  #---
  def available_purposes
    return Page.purposes if new_record?
    return Page.purposes.slice('route') if route?
    Page.purposes.slice('primary', 'secondary', 'banner', 'template')
  end

  def purpose_options
    available_purposes.keys.map { |p| [Page.human_attribute_value(:purpose, p), p] }
  end

  def can_be_nested?
    primary? || secondary?
  end

  def can_have_albums?
    primary? || secondary? || banner?
  end

  def needs_content?
    !route?
  end

  def slugger
    [:title, [:title, -> { store.name }]]
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
