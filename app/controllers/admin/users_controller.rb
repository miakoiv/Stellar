#encoding: utf-8

class Admin::UsersController < ApplicationController

  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  authorize_actions_for User, except: [:edit, :update]

  layout 'admin'

  # GET /admin/users
  # GET /admin/users.json
  def index
    @users = current_user.managed_users
  end

  # GET /admin/users/1
  # GET /admin/users/1.json
  def show
  end

  # GET /admin/users/new
  def new
    @user = current_store.users.build
  end

  # GET /admin/users/1/edit
  def edit
    authorize_action_for @user
  end

  # POST /admin/users
  # POST /admin/users.json
  def create
    @user = current_store.users.build(user_params)

    respond_to do |format|
      if @user.save
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
    authorize_action_for @user

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
    @user.destroy
    respond_to do |format|
      format.html { redirect_to admin_users_path,
        notice: t('.notice', user: @user) }
    end
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
        :group, :pricing_group_id, role_ids: [], category_ids: []
      )
    end
end
