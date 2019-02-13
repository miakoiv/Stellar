class SegmentAuthorizer < ApplicationAuthorizer

  def self.default(able, user, opts)
    user.has_cached_role?(:page_editor, opts[:at])
  end
end
