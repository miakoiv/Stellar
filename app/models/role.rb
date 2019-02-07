#encoding: utf-8

class Role < ActiveRecord::Base

  # Adds `creatable_by?(user)`, etc.
  include Authority::UserAbilities
  include Authority::Abilities
  resourcify
  scopify

  #---
  ROLES = {
    'superuser' => {icon: 'snowflake-o', appearance: 'danger'},
    'store_admin' => {icon: 'user-circle', appearance: 'danger'},
    'third_party' => {icon: 'user-circle-o', appearance: 'danger'},
    'customer_selection' => {icon: 'address-book-o', appearance: 'danger'},
    'user_manager' => {icon: 'users', appearance: 'success'},
    'inventory_manage' => {icon: 'cubes', appearance: 'success'},
    'asset_editor' => {icon: 'archive', appearance: 'success'},
    'page_editor' => {icon: 'files-o', appearance: 'info'},
    'product_editor' => {icon: 'cube', appearance: 'info'},
    'category_editor' => {icon: 'sitemap', appearance: 'info'},
    'property_editor' => {icon: 'eyedropper', appearance: 'info'},
    'promotion_editor' => {icon: 'tag', appearance: 'info'},
    'album_editor' => {icon: 'camera-retro', appearance: 'info'},
    'order_review' => {icon: 'truck', appearance: 'primary'},
    'order_manage' => {icon: 'truck', appearance: 'primary'},
    'reports' => {icon: 'line-chart', appearance: 'primary'},
    'order_notify' => {icon: 'envelope', appearance: 'primary'},
    'correspondence' => {icon: 'envelope', appearance: 'primary'},
  }.freeze

  #---
  has_and_belongs_to_many :users, join_table: :users_roles
  belongs_to :resource, polymorphic: true

  default_scope { order(:name) }
  scope :at, -> (store) {
    where(
      arel_table[:resource_type].eq(:store)
        .and(arel_table[:resource_id].eq(store))
      .or(arel_table[:resource_type].eq(nil)
        .and(arel_table[:resource_id].eq(nil)))
    )
  }

  #---
  validates :resource_type,
    inclusion: {in: Rolify.resource_types},
    allow_nil: true

  #---
  def self.available_roles
    ROLES.keys
  end

  # Roles that imply administrative capacity.
  def self.administrative
    available_roles - ['order_notify', 'correspondence']
  end

  # Roles granted at onboarding new store admins.
  def self.onboarding
    %w{store_admin user_manager inventory_manage page_editor product_editor category_editor property_editor promotion_editor order_review order_manage reports order_notify correspondence}
  end

  def self.icon_for(name)
    ROLES[name][:icon]
  end

  #---
  def to_s
    human_attribute_value(:name)
  end

  def icon
    ROLES[name][:icon]
  end

  def appearance
    ROLES[name][:appearance]
  end
end
