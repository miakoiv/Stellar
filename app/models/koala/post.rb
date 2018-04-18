#encoding: utf-8
#
# Koala::Post is a convenience model for posts coming from feeds
# like Facebook, fetched by Koala.

class Koala::Post

  include ActiveModel::Model

  attr_accessor :message, :picture, :link, :type, :created_at

  # Creation time comes from feeds as a string.
  def created_at=(str)
    @created_at = Time.zone.parse(str)
  end
end
