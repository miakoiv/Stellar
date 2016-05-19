#encoding: utf-8

class SnippetsController < ApplicationController

  # This controller is aware of unauthenticated guests.
  def current_user
    super || guest_user
  end

  # No layout, this controller never renders full pages.

  # GET /snippet/:type/:id
  def show
    type, id = params[:type], params[:id]
    @snippable = find_snippable(type, id)

    render partial: "#{type}", object: @snippable, as: type.to_sym
  end

  private
    def find_snippable(type, id)
      klass = type.classify.constantize
      if klass.respond_to?(:friendly)
        return klass.friendly.find(id)
      else
        return klass.find(id)
      end
    end
end
