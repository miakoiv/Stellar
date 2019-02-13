#encoding: utf-8

class Page < ApplicationRecord

  store :metadata, accessors: [
    :url
  ], coder: JSON

  # Pages must be aware of their routes since they may link to anything.
  include Rails.application.routes.url_helpers

  resourcify
  include Authority::Abilities
  include Trackable
  include Pictureable
  include Pageable
  include FriendlyId
  friendly_id :slugger, use: [:slugged, :scoped], scope: :store
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
    category_order: 6,  # link to category order
    header: 10,         # container for main navigation
    footer: 11,         # container for footer links
    dropdown: 20,       # dropdown container for other pages
    megamenu: 21,       # megamenu container for other pages
    continuous: 22,     # single page container for other pages
    contentmenu: 23,    # megamenu with its own layout and content
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
    'category_order' => {icon: 'list-ul', appearance: 'info'},
    'header' => {icon: 'navicon'},
    'footer' => {icon: 'paragraph'},
    'dropdown' => {icon: 'files-o', appearance: 'primary'},
    'megamenu' => {icon: 'window-maximize', appearance: 'primary'},
    'continuous' => {icon: 'scissors', appearance: 'primary'},
    'contentmenu' => {icon: 'address-card-o', appearance: 'primary'},
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
  scope :container, -> { where(purpose: [10, 11, 20, 21, 22]) }

  #---
  validates :title, presence: true
  validates :slug, presence: true, uniqueness: {scope: :store}, format: {with: /\A[a-z0-9_-]+\z/}

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

  def self.options_for_select(pages)
    [].tap do |options|
      each_with_level(pages.order(:lft)) do |p, l|
        options << yield(p, l)
      end
    end
  end

  #---
  def part_of_continuous_page?
    parent.present? && parent.continuous?
  end

  def can_have_children?
    category? || header? || footer? || dropdown? || megamenu? || continuous?
  end

  def can_have_content?
    primary? || template? || contentmenu? || portal?
  end

  def needs_resource?
    category? || product? || promotion? || department? || category_order? || portal? || proxy? || internal?
  end

  def movable?
    !(header? || footer?)
  end

  # Pages needing a resource can be live if the resource is live, or
  # doesn't understand the concept of being live in the first place.
  def can_be_live?
    return true unless needs_resource?
    resource.present? && (!resource.respond_to?(:live) || resource.live?)
  end

  # Creates a duplicate containing duplicates of sections on this page.
  def duplicate!
    clone = dup.tap do |c|
      c.rename_as_copy
      c.slug = nil
      c.save
      sections.each do |section|
        c.sections << section.duplicate
      end
      pictures.each do |picture|
        c.pictures << picture.duplicate
      end
    end
  end

  def slugger
    [:title, [:title, :id]]
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
    segments.reorder('sections.priority, columns.priority, segments.priority').map(&:content).join("\n")
  end

  # Pages are rendered with partials corresponding to purpose.
  def to_partial_path
    "pages/purposes/#{purpose}"
  end

  # Path to a page object based on purpose for rendering
  # navigation nodes pointing to the right place.
  def path
    case
    when primary?
      part_of_continuous_page? ?
        show_page_path(parent, trailing_slash: true, anchor: slug) :
        show_page_path(self)
    when route? || proxy?
      show_page_path(self)
    when category?
      show_category_path(resource)
    when product?
      show_product_path(resource)
    when promotion?
      show_promotion_path(resource)
    when department?
      show_department_path(resource)
    when category_order?
      show_category_order_path(resource)
    when dropdown? || megamenu?
      children.live.first.path
    when continuous?
      show_page_path(self, trailing_slash: true, anchor: children.live.primary.first.slug)
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
      [['store'], ['show_category', 'show_product', 'show_promotion', 'show_department', 'show_category_order']]
    when 'cart'
      [['store'], ['cart']]
    end
  end

  protected
    # Adds an incrementing duplicate number to the title.
    def rename_as_copy
      trunk, branch = title.partition(/ \(\d+\)/)
      branch = ' (0)' if branch.empty?
      self[:title] = "#{trunk}#{branch.succ}"
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
