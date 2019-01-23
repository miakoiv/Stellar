#encoding: utf-8

class Admin::UsersController < AdminController

  before_action :set_group, only: [:index, :new, :create, :join]
  before_action :set_user, only: [:show, :edit, :update, :destroy, :join]

  authority_actions join: 'update'

  # GET /admin/groups/1/users
  # GET /admin/groups/1/users.json
  def index
    authorize_action_for User, at: current_store
    query = saved_search_query('user', 'admin_user_search')
    @search = UserSearch.new(query.merge(search_params))
    @users = @search.results.page(params[:page])
  end

  # GET /admin/users/1
  # GET /admin/users/1.json
  def show
    authorize_action_for @user, at: current_store
    track @user
  end

  # GET /admin/groups/1/users/new
  def new
    authorize_action_for User, at: current_store
    @user = User.new
  end

  # GET /admin/users/1/edit
  def edit
    authorize_action_for @user, at: current_store
    track @user
  end

  # POST /admin/groups/1/users
  # POST /admin/groups/1/users.json
  def create
    authorize_action_for User, at: current_store
    if user = User.find_by(email: user_params[:email])
      return redirect_to edit_admin_user_path(user), alert: t('.exists', user: user)
    end
    @user = User.new(user_params.merge(approved: true))

    respond_to do |format|
      if @user.save
        track @user
        @user.groups << @group unless @user.groups.include?(@group)

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
        track @user
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
    @group = @user.group(current_store)
    track @user
    @user.destroy

    respond_to do |format|
      format.html { redirect_to admin_group_users_path(@group),
        notice: t('.notice', user: @user) }
    end
  end

  # PATCH /admin/groups/1/users/2/join
  def join
    authorize_action_for @user, at: current_store
    @groups = current_store.groups
    @user.groups.at(current_store).each do |group|
      @user.groups.delete(group)
    end
    @user.groups << @group
    track @user, nil, {action: 'update', differences: {group: @group}}

    respond_to :js
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = current_store.groups.find(params[:group_id])
    end

    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(
        :name, :email, :phone,
        :billing_address, :billing_postalcode,
        :billing_city, :billing_country_code,
        :shipping_address, :shipping_postalcode,
        :shipping_city, :shipping_country_code,
        :locale, :approved, :password, :password_confirmation
      )
    end

    # Restrict searching to users in selected group.
    def search_params
      {
        group: @group
      }
    end
end
