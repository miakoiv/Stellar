class Admin::GroupsController < AdminController

  include Reorderer

  before_action :set_group, only: [:show, :edit, :update, :destroy, :make_default, :select_categories, :toggle_category]

  authority_actions reorder: 'update', make_default: 'update', select_categories: 'update', toggle_category: 'update'

  # GET /admin/groups
  # GET /admin/groups.json
  def index
    authorize_action_for Group, at: current_store
    @groups = current_store.groups
  end

  # GET /admin/groups/1
  def show
    respond_to do |format|
      format.html { redirect_to edit_admin_group_path(@group) }
      format.json
    end
  end

  # GET /admin/groups/new.js
  def new
    authorize_action_for Group, at: current_store
    @group = current_store.groups.build
  end

  # GET /admin/groups/1/edit
  # GET /admin/groups/1/edit.js
  def edit
    authorize_action_for @group, at: current_store
    track @group
    @groups = current_store.groups

    respond_to :html, :js
  end

  # POST /admin/groups
  # POST /admin/groups.js
  # POST /admin/groups.json
  def create
    authorize_action_for Group, at: current_store
    @group = current_store.groups.build(group_params.merge(priority: current_store.groups.count))

    respond_to do |format|
      if @group.save
        track @group
        format.html { redirect_to edit_admin_group_path(@group),
          notice: t('.notice', group: @group) }
        format.js { flash.now[:notice] = t('.notice', group: @group) }
        format.json { render :edit, status: :created, location: edit_admin_group_path(@group) }
      else
        format.html { render :new }
        format.js { render :new }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/groups/1
  # PATCH/PUT /admin/groups/1.js
  # PATCH/PUT /admin/groups/1.json
  def update
    authorize_action_for @group, at: current_store

    respond_to do |format|
      if @group.update(group_params)
        track @group
        @groups = current_store.groups

        format.html { redirect_to admin_group_path(@group),
          notice: t('.notice', group: @group) }
        format.js { flash.now[:notice] = t('.notice', group: @group) }
        format.json { render :show, status: :ok, location: admin_group_path(@group) }
      else
        format.html { render :edit }
        format.js { render :edit }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/groups/1
  # DELETE /admin/groups/1.json
  def destroy
    authorize_action_for @group, at: current_store
    track @group
    @group.destroy

    respond_to do |format|
      format.html { redirect_to admin_groups_path,
        notice: t('.notice', group: @group) }
      format.json { head :no_content }
    end
  end

  # PATCH /admin/groups/1/make_default.js
  def make_default
    authorize_action_for @group, at: current_store
    @group.store.update default_group: @group
    @groups = current_store.groups

    respond_to :js
  end

  # GET /admin/groups/1/select_categories
  def select_categories
    authorize_action_for @group, at: current_store
  end

  # PATCH /admin/groups/1/toggle_category
  def toggle_category
    authorize_action_for @group, at: current_store
    @category = current_store.categories.find(params[:category_id])
    if @group.categories.include?(@category)
      @group.categories.delete(@category)
    else
      @group.categories << @category
    end

    respond_to :js
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = current_store.groups.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def group_params
      params.require(:group).permit(
        :name, :appearance,
        :pricing_shown, :stock_shown,
        :price_base, :price_modifier, :price_tax_included,
        :premium_group_id, :premium_teaser
      )
    end
end
