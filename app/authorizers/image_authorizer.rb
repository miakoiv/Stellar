#encoding: utf-8

class ImageAuthorizer < ApplicationAuthorizer

  def deletable_by?(user, opts)
    resource.pictures.none?
  end
end
