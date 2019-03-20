class Admin::MessagesController < AdminController

  before_action :set_message, only: [:show, :edit, :update, :destroy]

  # GET /admin/messages
  # GET /admin/messages.json
  def index
    authorize_action_for Message, at: current_store
    @messages = current_store.messages
  end

  # GET /admin/messages/1
  # GET /admin/messages/1.json
  def show
    authorize_action_for @message, at: current_store

    respond_to do |format|
      format.json { render json: @message, status: 200 }
      format.html
    end
  end

  # GET /admin/messages/new
  def new
    authorize_action_for Message, at: current_store
    @message = current_store.messages.build
  end

  # GET /admin/messages/1/edit
  def edit
    authorize_action_for @message, at: current_store
  end

  # POST /admin/messages
  # POST /admin/messages.json
  def create
    authorize_action_for Message, at: current_store
    @message = current_store.messages.build(message_params)

    respond_to do |format|
      if @message.save
        track @message
        format.html { redirect_to admin_message_path(@message),
          notice: t('.notice', message: @message) }
        format.json { render :show, status: :created, location: admin_message_path(@message) }
      else
        format.html { render :new }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/messages/1
  # PATCH/PUT /admin/messages/1.json
  def update
    authorize_action_for @message, at: current_store

    respond_to do |format|
      if @message.update(message_params)
        track @message
        format.html { redirect_to admin_message_path(@message),
          notice: t('.notice', message: @message) }
        format.json { render :show, status: :ok, location: admin_message_path(@message) }
      else
        format.html { render :edit }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/messages/1
  # DELETE /admin/messages/1.json
  def destroy
    authorize_action_for @message, at: current_store
    track @message
    @message.destroy

    respond_to do |format|
      format.html { redirect_to admin_messages_path,
        notice: t('.notice', message: @message) }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = current_store.messages.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def message_params
      params.require(:message).permit(
        :context_type, :context_id, :context_gid, :stage, :disabled, :content
      )
    end
end
