class SegmentAuthorizer < ApplicationAuthorizer

  def self.default(able, user, opts)
    user.has_cached_role?(:page_editor, opts[:at])
  end

  def deletable_by?(user, opts)
    return false if resource.referring_segments.any?
    user.has_cached_role?(:page_editor, opts[:at])
  end
end
