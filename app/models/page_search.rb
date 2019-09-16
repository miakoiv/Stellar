class PageSearch < Searchlight::Search

  def base_query
    Page.includes(:sections).joins(:segments)
  end

  def search_store
    query.where(store: store)
  end

  def search_group
    query.visible(group)
  end

  def search_within
    query.where(Page.arel_table[:lft].gteq(within.lft)).where(Page.arel_table[:rgt].lt(within.rgt))
  end

  def search_keyword
    q = '%%%s%%' % keyword.gsub(/[%_]/, '\\\\\0')
    query.live.searchable.distinct.where(
      Page.arel_table[:title].matches(q)
        .or(Segment.arel_table[:content].matches(q))
    )
  end
end
