#encoding: utf-8

class Page < ActiveRecord::Base

  store :metadata, accessors: [
    :url
  ], coder: JSON

  # Pages must be aware of their routes since they may link to anything.
  include Rails.application.routes.url_helpers

  resourcify
  include Authority::Abilities
  include Imageable
  include Pageable
  include FriendlyId
  friendly_id :slugger, use: [:slugged, :scoped, :history], scope: :store
  acts_as_nested_set scope: :store,
                     dependent: :destroy,
                     counter_cache: :children_count

  #---
  enum purpose: {
    route: 0,           # navigation node routed to #slug
    primary: 1,         # page with content sections
    category: 2,        # link to category
    product: 3,         # link to product
    promotion: 4,       # link to promotion
    department: 5,      # link to department
    header: 10,         # container for main navigation
    footer: 11,         # container for footer links
    dropdown: 20,       # dropdown container for other pages
    megamenu: 21,       # megamenu container for other pages
    template: 30,       # printed page template
    portal: 40,         # page with content sections meant for portals
    proxy: 41,          # proxy to a portal page for portal navigation
    external: 42,       # link to an external page (url)
    internal: 43,       # link to an internal page
  }

  PRESENTATION = {
    'route' => {icon: 'share-alt', appearance: 'danger'},
    'primary' => {icon: 'file-text-o', appearance: 'success'},
    'category' => {icon: 'sitemap', appearance: 'info'},
    'product' => {icon: 'cube', appearance: 'info'},
    'promotion' => {icon: 'tag', appearance: 'info'},
    'department' => {icon: 'umbrella', appearance: 'info'},
    'header' => {icon: 'navicon'},
    'footer' => {icon: 'paragraph'},
    'dropdown' => {icon: 'files-o', appearance: 'primary'},
    'megamenu' => {icon: 'window-maximize', appearance: 'primary'},
    'template' => {icon: 'file-o', appearance: 'warning'},
    'portal' => {icon: 'globe', appearance: 'success'},
    'proxy' => {icon: 'share', appearance: 'success'},
    'external' => {icon: 'share', appearance: 'danger'},
    'internal' => {icon: 'share-alt', appearance: 'danger'},
  }.freeze

  #---
  belongs_to :store

  # Resource is anything the page may refer to, depending on its purpose.
  belongs_to :resource, polymorphic: true

  has_many :sections, dependent: :destroy
  has_many :segments, through: :sections

  scope :live, -> { where(live: true) }
  scope :excluding, -> (page) { where.not(id: page) }

  # Containers for other pages. Segments target these to build navs.
  scope :container, -> { where(purpose: [20, 21]) }

  #---
  validates :title, presence: true
  validates :resource, presence: true,
    if: -> (page) { page.needs_resource? },
    on: :update

  #---
  before_save :conditionally_disable
  after_save :touch_resource

  #---
  # Finds the first page that returns a non-nil path.
  def self.entry_point
    find { |page| page.path }
  end

  def self.available_purposes
    purposes.except :header, :footer
  end

  def self.purpose_options
    available_purposes.keys.map { |p| [Page.human_attribute_value(:purpose, p), p] }
  end

  #---
  def can_have_children?
    category? || header? || footer? || dropdown? || megamenu?
  end

  def can_have_content?
    primary? || template? || portal?
  end

  def needs_resource?
    category? || product? || promotion? || department? || portal? || proxy?
  end

  def movable?
    return false if needs_resource? && resource.nil?
    !(header? || footer?)
  end

  # Pages with a resource can be live if the resource is live, or
  # doesn't understand the concept of being live in the first place.
  def can_be_live?
    resource.nil? || !resource.respond_to?(:live) || resource.live?
  end

  def slugger
    [:title, [:title, :id]]
  end

  # Prevent FriendlyId from changing slugs on route and external pages.
  def should_generate_new_friendly_id?
    !(route? || external?) && title_changed? || super
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

  def label
    return '' if header? || footer?
    return slug if route?
    resource || Page.human_attribute_value(:purpose, purpose)
  end

  def description
    segments.map(&:content).join("\n")
  end

  # Pages are rendered with partials corresponding to purpose.
  def to_partial_path
    "pages/purposes/#{purpose}"
  end

  # Path to a page object based on purpose for rendering
  # navigation nodes pointing to the right place.
  def path
    case
    when route? || primary? || proxy?
      show_page_path(self)
    when category?
      show_category_path(resource)
    when product?
      show_product_path(resource)
    when promotion?
      show_promotion_path(resource)
    when department?
      show_department_path(resource)
    when dropdown? || megamenu?
      children.first.path
    when portal?
      resource.to_url
    when internal?
      show_page_path(resource)
    else nil
    end
  end

  # Route pages ask this method to render their links with
  # active_link_to, since the page with a slug of 'front'
  # should be active for all category and product pages.
  def active_link_options
    case slug
    when 'front'
      [['store'], ['show_category', 'show_product', 'show_promotion', 'show_department']]
    when 'cart'
      [['store'], ['cart']]
    end
  end

  def to_option
    self_and_ancestors.join " \u23f5 "
  end

  private
    def touch_resource
      resource.touch if resource.present?
    end

    def conditionally_disable
      self.live = false unless can_be_live?
      true
    end
end
