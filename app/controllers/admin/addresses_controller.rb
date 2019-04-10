class Admin::AddressesController < AdminController

  before_action :find_addressed
  before_action :set_type, only: [:new, :create, :update, :destroy]

  # GET /admin/addresses?gid=addressed
  def index
    respond_to :js
  end

  # GET /admin/addresses/new?gid=addressed
  def new
    @address = Address.default(current_store)

    respond_to do |format|
      format.js { render :refresh }
    end
  end

  # POST /admin/addresses
  def create
    authorize_action_for Address, at: current_store
    @address = Address.new(address_params)

    respond_to do |format|
      if @address.save && @addressed.update_address(@type, @address)
        format.js {
          flash.now[:notice] = t('.notice', addressed: @addressed)
          render :refresh
        }
      else
        format.js { render :refresh }
      end
    end
  end

  # PATCH/PUT /admin/addresses/1
  def update
    authorize_action_for Address, at: current_store
    @address = Address.find(params[:id])

    respond_to do |format|
      if @address.update(address_params)
        format.js {
          flash.now[:notice] = t('.notice', addressed: @addressed)
          render :refresh
        }
      else
        format.js { render :refresh }
      end
    end
  end

  # DELETE /admin/addresses/1?gid=addressed
  def destroy
    authorize_action_for Address, at: current_store
    @address = Address.find(params[:id])

    respond_to do |format|
      if @address.destroy && @addressed.update_address(@type, nil)
        @address = nil
        format.js {
          flash.now[:notice] = t('.notice', addressed: @addressed)
          render :refresh
        }
      end
    end
  end

  private
    # Finds the associated addressed object by global id.
    def find_addressed
      @addressed = GlobalID::Locator.locate(params[:gid])
    end

    def set_type
      @type = params[:type].to_sym
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def address_params
      params.require(:address).permit(
        :name, :phone, :company,
        :address1, :address2, :postalcode, :city, :country_code
      )
    end
end
