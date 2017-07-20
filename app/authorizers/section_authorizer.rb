#encoding: utf-8

class SectionAuthorizer < ApplicationAuthorizer

  def self.default(able, user)
    user.has_cached_role?(:page_editor)
  end
end
