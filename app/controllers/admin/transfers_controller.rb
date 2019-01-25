#encoding: utf-8

class Admin::TransfersController < AdminController

  before_action :set_transfer, except: [:index, :new, :create]

  authority_actions complete: 'update'

  # GET /admin/transfers
  def index
    authorize_action_for Transfer, at: current_store
    query = saved_search_query('transfer', 'admin_transfer_search')
    @search = TransferSearch.new(query.merge(search_params))
    results = @search.results
    @transfers = results.page(params[:page])
  end

  # GET /admin/transfers/1
  def show
    authorize_action_for @transfer, at: current_store
  end

  # GET /admin/transfers/new
  def new
    authorize_action_for Transfer, at: current_store
    @transfer = current_store.transfers.build
  end

  # GET /admin/transfers/1/edit
  def edit
    authorize_action_for @transfer, at: current_store
  end

  # POST /admin/transfers
  # POST /admin/transfers.json
  def create
    authorize_action_for Transfer, at: current_store
    @transfer = current_store.transfers.build(transfer_params)

    respond_to do |format|
      if @transfer.save
        track @transfer
        format.html { redirect_to edit_admin_transfer_path(@transfer),
          notice: t('.notice', transfer: @transfer) }
        format.json { render :show, status: :created, location: admin_transfer_path(@transfer) }
      else
        format.html { render :new }
        format.json { render json: @transfer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/transfers/1
  # PATCH/PUT /admin/transfers/1.json
  def update
    authorize_action_for @transfer, at: current_store

    respond_to do |format|
      if @transfer.update(transfer_params)
        track @transfer
        format.html { redirect_to admin_transfer_path(@transfer),
          notice: t('.notice', transfer: @transfer) }
        format.json { render :show, status: :ok, location: admin_transfer_path(@transfer) }
      else
        format.html { render :edit }
        format.json { render json: @transfer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/transfers/1
  # DELETE /admin/transfers/1.json
  def destroy
    authorize_action_for @transfer, at: current_store
    track @transfer
    @transfer.destroy

    respond_to do |format|
      format.html { redirect_to admin_transfers_path,
        notice: t('.notice', transfer: @transfer) }
      format.json { head :no_content }
    end
  end

  # PATCH/PUT /admin/transfers/1/complete
  def complete
    authorize_action_for @transfer, at: current_store

    respond_to do |format|
      if @transfer.complete!
        track @transfer, nil, {action: 'conclude'}
        format.html { redirect_to admin_transfer_path(@transfer), notice: t('.notice', transfer: @transfer) }
        format.json { render :show, status: :ok, location: admin_transfer_path(@transfer) }
      else
        format.html { render :show }
        format.json { render json: @transfer.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transfer
      @transfer = current_store.transfers.find(params[:id])
    end

    def transfer_params
      params.require(:transfer).permit(
        :source_id, :destination_id, :note
      )
    end

    def search_params
      {
        store: current_store
      }
    end
end
