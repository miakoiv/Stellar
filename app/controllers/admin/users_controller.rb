#encoding: utf-8

class Admin::UsersController < ApplicationController

  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update, :destroy, :set_pricing_group, :toggle_category]

  authority_actions set_pricing_group: 'update', toggle_category: 'update'

  layout 'admin'

  # GET /admin/users
  # GET /admin/users.json
  def index
    authorize_action_for User, at: current_store
    @users = current_user.managed_users(current_store)
  end

  # GET /admin/users/1
  # GET /admin/users/1.json
  def show
    authorize_action_for @user, at: current_store
  end

  # GET /admin/users/new
  def new
    authorize_action_for User, at: current_store
    @user = User.new(store: current_store)
  end

  # GET /admin/users/1/edit
  def edit
    authorize_action_for @user, at: current_store
  end

  # POST /admin/users
  # POST /admin/users.json
  def create
    authorize_action_for User, at: current_store
    @user = User.new(user_params.merge(store: current_store))

    respond_to do |format|
      if @user.save
        @user.grant(:see_pricing, current_store)
        @user.grant(:see_stock, current_store)

        format.html { redirect_to edit_admin_user_path(@user),
          notice: t('.notice', user: @user) }
        format.json { render :show, status: :created, location: admin_user_path(@user) }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/users/1
  # PATCH/PUT /admin/users/1.json
  def update
    authorize_action_for @user, at: current_store

    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to admin_user_path(@user),
          notice: t('.notice', user: @user) }
        format.json { render :show, status: :ok, location: admin_user_path(@user) }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/users/1
  def destroy
    authorize_action_for @user, at: current_store
    @user.destroy

    respond_to do |format|
      format.html { redirect_to admin_users_path,
        notice: t('.notice', user: @user) }
    end
  end

  # PATCH /admin/users/1/set_pricing_group
  def set_pricing_group
    authorize_action_for @user, at: current_store
    group = current_store.pricing_groups.find(params[:group_id])

    # Selecting the current pricing group clears the selection.
    clear = @user.pricing_group(current_store) == group
    @user.pricing_groups.at(current_store).each do |group|
      @user.pricing_groups.delete(group)
    end
    @user.pricing_groups << group unless clear

    respond_to :js
  end

  # PATCH /admin/users/1/toggle_category
  def toggle_category
    authorize_action_for @user, at: current_store
    @category = current_store.categories.find(params[:category_id])
    if @user.categories.include?(@category)
      @user.categories.delete(@category)
    else
      @user.categories << @category
    end

    respond_to :js
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = current_store.users.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(
        :name, :email, :phone,
        :billing_address, :billing_postalcode,
        :billing_city, :billing_country_code,
        :shipping_address, :shipping_postalcode,
        :shipping_city, :shipping_country_code,
        :locale, :password, :password_confirmation,
        :group
      )
    end
end
