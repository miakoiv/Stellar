#encoding: utf-8

class Admin::ActivitiesController < ApplicationController

  before_action :authenticate_user!
  before_action :set_activity, only: [:show]

  layout 'admin'

  # GET /activities
  # GET /activities.json
  def index
    authorize_action_for Activity, at: current_store
    @query = saved_search_query('activity', 'admin_activity_search')
    @search = ActivitySearch.new(search_params)
    @activities = @search.results.page(params[:page])
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_activity
      @activity = Activity.find(params[:id])
    end

    # Restrict searching to activities in current store.
    def search_params
      @query.merge(
        store: current_store
      )
    end
end
