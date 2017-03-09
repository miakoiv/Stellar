#encoding: utf-8

class Page < ActiveRecord::Base

  # Pages must be aware of their routes since they may link to anything.
  include Rails.application.routes.url_helpers

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
  validates :resource, presence: true,
    if: -> (page) { page.product_link? }

  #---
  # Finds the first page that returns a non-nil path.
  def self.entry_point
    find { |page| page.path }
  end

  def self.available_purposes
    purposes.slice(
      :route, :primary, :template,
      :category_menu, :product_link, :navigation
    )
  end

  def self.purpose_options
    available_purposes.keys.map { |p| [Page.human_attribute_value(:purpose, p), p] }
  end

  #---
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

  # Path to a page object depends on its purpose. Route and primary pages
  # use plain page routes, product link pages point to the target product.
  # Navigation pages point to their first child, category menu pages point
  # to their target, or first child if target is nil.
  def path
    return show_page_path(self) if route? || primary?
    return children.first.path if navigation?
    return show_product_path(resource.category, resource) if product_link?
    return show_category_path(resource || store.first_category) if category_menu?
    nil
  end
end
