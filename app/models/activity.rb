#
# Activities are records of actions taken by users on resources in
# a certain context. The context may be the resource itself, or its
# relational parent record, with which the activity should appear.
#
class Activity < ApplicationRecord

  paginates_per 15

  include Authority::Abilities

  belongs_to :store
  belongs_to :user
  belongs_to :resource, polymorphic: true
  belongs_to :context, polymorphic: true

  serialize :differences, JSON

  default_scope { order(id: :desc) }

  #---
  ACTIONS = {
    show: {icon: 'info-circle', appearance: 'info'},
    edit: {icon: 'pencil-square', appearance: 'info'},
    create: {icon: 'plus-circle', appearance: 'success'},
    update: {icon: 'pencil-square', appearance: 'success'},
    destroy: {icon: 'times-circle', appearance: 'warning'},
    approve: {icon: 'check', appearance: 'primary'},
    complete: {icon: 'check', appearance: 'primary'},
    conclude: {icon: 'gavel', appearance: 'primary'},
    discard: {icon: 'times', appearance: 'danger'},
    grant: {icon: 'dot-circle-o', appearance: 'danger'},
    revoke: {icon: 'circle-o', appearance: 'danger'}
  }.freeze

  #---
  def icon
    ACTIONS[action.to_sym][:icon]
  end

  def appearance
    ACTIONS[action.to_sym][:appearance]
  end

  def resource_class
    resource_type.constantize
  end

  def to_s
    "#{model_name.human.capitalize} #{created_at.year}-#{id}"
  end
end
