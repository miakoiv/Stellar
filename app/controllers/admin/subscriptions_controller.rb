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
end
