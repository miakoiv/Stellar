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
      end
      format.js do
        @plan = Plan.new(stripe_plan_id: params[:stripe_plan_id])
      end
    end
  end

  # POST /admin/subscriptions
  def create
    authorize_action_for Subscription, at: current_store

    begin
      @plans = Plan.all
      @subscription = StripeGateway::SubscriptionService.new(
        store: current_store,
        user: current_user,
        stripe_plan_id: subscription_params[:stripe_plan_id],
        stripe_source_id: subscription_params[:stripe_source_id]
      ).subscribe!

      redirect_to admin_subscriptions_path, notice: t('.notice')

    rescue Stripe::CardError => e
      flash.now[:error] = t('.card_error')
      render :new
    rescue => e
      flash.now[:error] = t('.error')
      render :new
    end
  end

  # DELETE /admin/subscriptions/1
  def destroy
    authorize_action_for @subscription, at: current_store

    begin
      StripeGateway::CancellationService.new(@subscription).cancel!
    rescue => e
      flash[:error] = t('.error')
    end

    redirect_to admin_subscriptions_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_subscription
      @subscription = current_store.subscriptions.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def subscription_params
      params.require(:subscription).permit(
        :stripe_plan_id, :stripe_source_id
      )
    end
end
