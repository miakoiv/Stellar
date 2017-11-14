#encoding: utf-8

require 'searchlight/adapters/action_view'

class CategorySearch < Searchlight::Search

  include Searchlight::Adapters::ActionView

  def base_query
    Category.order(:lft)
  end

  def search_store
    query.where(store: store)
  end

  def search_keyword
    query.where('name LIKE ?', "%#{keyword}%")
  end

  def search_live
    query.where(live: live)
  end
end
