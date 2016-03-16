#encoding: utf-8

class CheckoutController < ApplicationController

  # This controller is aware of unauthenticated guests.
  def current_user
    super || guest_user
  end

  before_action :authenticate_user_or_skip!
  before_action :set_pages
  before_action :find_order

  # GET /checkout/1/via/2
  # Entering checkout sets the order type, which tells us how to reappraise
  # the order items (trade price for resellers ordering from manufacturers),
  # and whether a payment is required.
  def checkout
    @order.order_type = current_store.order_types.find(params[:order_type_id])
    @order.reappraise!

    if @order.empty? || !@order.checkoutable?
      return redirect_to cart_path
    end

    if @order.has_payment?
      @payment_gateway = @order.payment_gateway.new(order: @order)
    end
  end

  # GET /checkout/1/pay/credit_card.json
  def pay
    method = params[:method]

    if method.present? && @order.has_payment?
      @payment_gateway = @order.payment_gateway.new(order: @order, return_url: return_url(@order))
      response = @payment_gateway.send("charge_#{method}", params)
      render json: response
    else
      head :bad_request
    end
  end

  # POST /checkout/1/verify.json
  def verify
    token = params[:token]

    @payment_gateway = @order.payment_gateway.new(order: @order)
    status = @payment_gateway.verify(token)

    if status
      unless @order.paid?
        @order.payments.create(amount: @order.grand_total)
      end
      head :ok
    else
      head :bad_request
    end
  end

  # GET /checkout/1/return
  def return
    @payment_gateway = @order.payment_gateway.new(order: @order)
    status = @payment_gateway.return(params)
    if status
      @order.payments.create(amount: @order.grand_total)
      render :success
    else
      render :checkout
    end
  end

  private
    def find_order
      @order = current_user.orders.find(params[:order_id])
    end
end
