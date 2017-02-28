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
    route: 0,         # navigation node routed to #slug
    primary: 1,       # page with content sections
    secondary: 2,     # secondary content (deprecated)
    banner: 3,        # banner container (deprecated)
    template: 4,      # printed page template
    category_menu: 6, # menu from linked category (or root if nil)
    product_link: 7,  # link to product
    header: 10,       # virtual page containing main navigation
    footer: 11,       # virtual page containing footer links
    navigation: 12,   # secondary navigation
  }

  PRESENTATION = {
    'route' => {icon: '', appearance: 'danger'},
    'primary' => {icon: 'file-text-o', appearance: 'success'},
    'secondary' => {icon: 'file-text-o', appearance: 'success'},
    'banner' => {icon: ''},
    'template' => {icon: 'file-o', appearance: 'warning'},
    'category_menu' => {icon: 'sitemap', appearance: 'info'},
    'product_link' => {icon: 'cube', appearance: 'info'},
    'header' => {icon: 'navicon'},
    'footer' => {icon: 'paragraph'},
    'navigation' => {icon: 'share-alt'}
  }.freeze

  #---
  belongs_to :store

  # Resource is anything the page may refer to, depending on its purpose.
  belongs_to :resource, polymorphic: true

  has_and_belongs_to_many :albums

  #---
  validates :title, presence: true

  #---
  def self.navigable
    select { |page| page.is_navigable? }
  end

  def self.available_purposes
    purposes.slice(
      :route, :primary, :template,
      :category_menu, :navigation
    )
  end

  def self.purpose_options
    available_purposes.keys.map { |p| [Page.human_attribute_value(:purpose, p), p] }
  end

  #---
  # Page can be navigated to if it has content to present.
  # FIXME: once category pages are implemented, allow navigation to
  #        pages with target category assigned
  def is_navigable?
    return true if route? || primary? || category_menu? || product_link?
    false
  end

  def can_have_children?
    header? || footer? || navigation?
  end

  def can_have_content?
    primary? || template?
  end

  def movable?
    route? || primary? || navigation? || category_menu? || product_link?
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
    return human_attribute_value(:purpose) if header? || footer?
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
