#encoding: utf-8

require 'searchlight/adapters/action_view'

class UserSearch < Searchlight::Search

  include Searchlight::Adapters::ActionView

  def base_query
    User.joins(:groups).order(:name)
  end

  def search_store
    query.where(groups: {store: store})
  end

  def search_group
    query.where(groups: {id: group})
  end

  def search_except_group
    query.where.not(groups: {id: except_group})
  end

  def search_keyword
    query.where("CONCAT_WS(' ', users.email, users.name) LIKE ?", "%#{keyword}%")
  end
end
