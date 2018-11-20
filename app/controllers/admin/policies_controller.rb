#encoding: utf-8

class Admin::PoliciesController < ApplicationController

  before_action :authenticate_user!
  before_action :set_policy, only: [:show, :edit, :update, :accept]

  authority_actions accept: :accept

  layout 'admin'

  # GET /policies
  # GET /policies.json
  def index
    authorize_action_for Policy, at: current_store
    @policies = current_store.policies
  end

  # GET /admin/policies/1
  # GET /admin/policies/1.json
  def show
    authorize_action_for Policy, at: current_store
  end

  # GET /admin/policies/new
  def new
    authorize_action_for Policy, at: current_store
    @policy = current_store.policies.build
  end

  # GET /admin/policies/1/edit
  def edit
    authorize_action_for @policy, at: current_store
  end

  # POST /admin/policies
  # POST /admin/policies.json
  def create
    authorize_action_for Policy, at: current_store
    @policy = current_store.policies.build(policy_params)

    respond_to do |format|
      if @policy.save
        track @policy
        format.html { redirect_to admin_policy_path(@policy), notice: t('.notice', policy: @policy) }
        format.json { render :show, status: :created, location: admin_policy_path(@policy) }
      else
        format.html { render :new }
        format.json { render json: @policy.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/policies/1
  # PATCH/PUT /admin/policies/1.json
  def update
    authorize_action_for @policy, at: current_store

    respond_to do |format|
      if @policy.update(policy_params)
        track @policy
        format.html { redirect_to admin_policy_path(@policy), notice: t('.notice', policy: @policy) }
        format.json { render :show, status: :ok, location: admin_policy_path(@policy) }
      else
        format.html { render :edit }
        format.json { render json: @policy.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/policies/1/accept
  def accept
    authorize_action_for @policy, at: current_store

    respond_to do |format|
      if params[:policy][:accepted] == '1'
        @policy.update!(accepted_at: Time.current, accepted_by: current_user)
        track @policy, nil, {action: 'approve'}
        format.html { redirect_to admin_policy_path(@policy), notice: t('.notice', policy: @policy) }
      else
        format.html { render :show }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_policy
      @policy = current_store.policies.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def policy_params
      params.require(:policy).permit(
        :title, :content, :mandatory
      )
    end
end
