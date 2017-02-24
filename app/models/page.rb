#encoding: utf-8

class Page < ActiveRecord::Base

  resourcify
  include Authority::Abilities
  include Imageable
  include FriendlyId
  friendly_id :slugger, use: [:slugged, :history]
  acts_as_nested_set scope: :store,
                     dependent: :nullify,
                     counter_cache: :children_count

  #---
  enum purpose: {
    route: 0,       # navigation node routed to #slug
    primary: 1,     # page with content sections
    secondary: 2,   # secondary content (deprecated)
    banner: 3,      # banner container (deprecated)
    template: 4,    # printed page template
    navigation: 5,  # navigation menu containing other pages
    category: 6,    # navigation node to linked category (or categories root)
    header: 7,      # virtual page containing main navigation
    footer: 8,      # virtual page containing footer links
  }

  PRESENTATION = {
    'route' => {icon: '', appearance: 'danger'},
    'primary' => {icon: 'file-text-o', appearance: 'success'},
    'secondary' => {icon: 'file-text-o', appearance: 'success'},
    'banner' => {icon: ''},
    'template' => {icon: 'file-o', appearance: 'warning'},
    'navigation' => {icon: 'share-alt'},
    'category' => {icon: 'sitemap', appearance: 'info'},
    'header' => {icon: 'navicon'},
    'footer' => {icon: 'paragraph'}
  }.freeze

  #---
  belongs_to :store
  has_and_belongs_to_many :albums

  #---
  validates :title, presence: true,
    unless: -> (page) { page.header? || page.footer? }

  #---
  def self.available_purposes
    purposes.slice(:route, :primary, :template, :navigation, :category)
  end

  def self.purpose_options
    available_purposes.keys.map { |p| [Page.human_attribute_value(:purpose, p), p] }
  end

  #---
  def can_have_children?
    navigation? || header? || footer?
  end

  def can_have_content?
    primary? || template?
  end

  def movable?
    route? || primary? || navigation? || category?
  end

  def can_have_albums?
    primary?
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

  def icon
    Page::PRESENTATION[purpose][:icon]
  end

  def appearance
    Page::PRESENTATION[purpose][:appearance]
  end

  def description
    content
  end

  def to_partial_path
    "pages/#{purpose}"
  end
end
