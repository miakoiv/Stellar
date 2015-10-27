#encoding: utf-8

class Admin::CustomizationsController < ApplicationController

  before_action :authenticate_user!

  # No layout, this controller never renders HTML.

  # POST /admin/customizable/1/customizations
  def create
    @customizable = find_customizable
    @custom_attribute = CustomAttribute.find_by(id: params[:customization][:custom_attribute_id])
    if @custom_attribute.present?
      @customization = @customizable.customizations.find_or_create_by(
        custom_attribute: @custom_attribute
      ).update(customization_params)
    end

    respond_to do |format|
      format.js
    end
  end

  # DELETE /admin/customizations/1
  def destroy
    @customization = Customization.find(params[:id])

    respond_to do |format|
      if @customization.destroy
        format.js
      end
    end
  end

  private
    # Finds the associated customizable by looking through params.
    def find_customizable
      params.each do |name, value|
        if name =~ /(.+)_id$/
          klass = $1.classify.constantize
          if klass.respond_to?(:friendly)
            return klass.friendly.find(value)
          else
            return klass.find(value)
          end
        end
      end
      nil
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def customization_params
      params.require(:customization).permit(
        :custom_attribute_id, :custom_value_id, :value
      )
    end
end
