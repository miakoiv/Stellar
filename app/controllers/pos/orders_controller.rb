class Pos::OrdersController < ApplicationController

  before_action :authenticate_user!
  before_action :set_order, only: [:update]

  layout 'point_of_sale'

  # PATCH/PUT /pos/orders/1
  def update
    respond_to do |format|
      if @order.update(order_params)
        format.js
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = current_user.orders.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(
        :order_type_id, :customer_id,
        :shipping_at, :installation_at,
        :vat_number, :your_reference, :our_reference, :message,
        :customer_name, :customer_email, :customer_phone,
        :company_name, :contact_person, :contact_email, :contact_phone,
        :has_billing_address,
        :billing_address, :billing_postalcode,
        :billing_city, :billing_country_code,
        :shipping_address, :shipping_postalcode,
        :shipping_city, :shipping_country_code,
        :notes,
        customer_attributes: [
          :id, :initial_group_id, :email, :name, :phone,
          :shipping_address, :shipping_postalcode,
          :shipping_city, :shipping_country_code,
          :billing_address, :billing_postalcode,
          :billing_city, :billing_country_code
        ]
      )
    end
end
