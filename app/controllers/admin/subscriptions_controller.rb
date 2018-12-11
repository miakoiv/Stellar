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
  def new
    authorize_action_for Subscription, at: current_store
    @plans = Plan.all
    @subscription = current_store.subscriptions.new
  end
end
