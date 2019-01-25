#encoding: utf-8
#
# This controller only handles a single task: rendering orders
# in XML format using Builder. No routes point to this controller,
# hence rendering happens by calling #render.
#
class Admin::OrderExportsController < AdminController

  # GET /admin/order_exports/1.xml
  def show
    respond_to do |format|
      format.xml
    end
  end
end
