module Reorderable
  extend ActiveSupport::Concern

  included do

    # Available scopes to sort without manual (priority) ordering.
    cattr_accessor :sorting_scopes do
      []
    end

    def self.define_scope(name, &block)
      self.singleton_class.send(:define_method, name.to_sym, &block)
      sorting_scopes << name.to_sym
    end

    def self.sorted(scope = nil)
      scope = :manual unless scope.present?
      self.send(scope)
    end

    define_scope :manual do
      order(:priority)
    end
  end
end
