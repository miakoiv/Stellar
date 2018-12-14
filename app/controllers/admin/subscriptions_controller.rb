#encoding: utf-8

class Admin::SubscriptionsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_subscription, except: [:index, :new, :create]

  layout 'admin'

  # GET /admin/subscriptions
  def index
    authorize_action_for Subscription, at: current_store
    @subscriptions = current_store.subscriptions
  end

  # GET /admin/subscriptions/new
  # GET /admin/subscriptions/new.js
  def new
    authorize_action_for Subscription, at: current_store

    respond_to do |format|
      format.html do
        @plans = Plan.all
        @subscription = current_store.subscriptions.build(
          customer: current_user
        )
      end
      format.js do
        @plan = Plan.new(stripe_plan_id: params[:stripe_plan_id])
      end
    end
  end

  # POST /admin/subscriptions
  def create
    authorize_action_for Subscription, at: current_store

    @subscription = current_store.subscriptions.build(subscription_params)
    logger.info params

    respond_to do |format|
      format.html { redirect_to admin_subscriptions_path, notice: t('.notice', subscription: @subscription) }
      format.json { render :show, status: :created, location: admin_subscription_path(@subscription) }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_subscription
      @subscription = current_store.subscriptions.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def subscription_params
      params.require(:subscription).permit(
        :stripe_plan_id, :stripe_token
      )
    end
end
