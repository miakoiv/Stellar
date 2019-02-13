#
# Order export generates XML output and writes it into
# the directory at specified path.
#
class OrderExportJob < ApplicationJob
  queue_as :default

  def perform(order, path)
    filename = "#{order.store}-#{order.number}.xml"
    xml = Admin::OrderExportsController.render :show, assigns: {order: order}
    File.open(File.join(path, filename), 'w') do |f|
      f.write(xml)
    end
  end
end
