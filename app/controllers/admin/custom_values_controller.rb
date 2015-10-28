#encoding: utf-8

class Admin::CustomValuesController < ApplicationController

  include Reorderer
  before_action :authenticate_user!
  before_action :set_custom_attribute, only: [:create]

  # No layout, this controller never renders HTML.

  # POST /admin/custom_attributes/1/custom_values
  def create
    @custom_value = @custom_attribute.custom_values.build(custom_value_params)
    @custom_value.priority = @custom_attribute.custom_values.count

    respond_to do |format|
      if @custom_value.save
        format.json { render json: @custom_value, status: 200 } # for selectize.js
        format.js
      end
    end
  end

  # PATCH/PUT /admin/custom_values/1
  def update
    @custom_value = CustomValue.find(params[:id])

    respond_to do |format|
      if @custom_value.update(custom_value_params)
        format.js
      end
    end
  end

  # DELETE /admin/custom_values/1
  def destroy
    @custom_value = CustomValue.find(params[:id])

    respond_to do |format|
      if @custom_value.destroy
        format.js
      end
    end
  end

  private
    def set_custom_attribute
      @custom_attribute = current_store.custom_attributes.find(params[:custom_attribute_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def custom_value_params
      params.require(:custom_value).permit(
        :value, :priority
      )
    end
end
