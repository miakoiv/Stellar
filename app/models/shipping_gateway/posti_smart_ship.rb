#
# Implementation of shipping methods available through the Posti SmartShip
# (Unifaun) API. Different shipping methods are defined as subclasses of
# ShippingGateway::PostiSmartShip::Base.
#
module ShippingGateway
  module PostiSmartShip
    class Base
      include ActiveModel::Model

      TEST_KEY = ''
      TEST_SECRET = ''

      attr_accessor :order, :shipment, :user, :data

      def self.fixed_cost?
        true
      end

      def self.requires_dimensions?
        true
      end

      def self.generates_labels?
        true
      end

      def initialize(attributes = {})
        super
        raise ShippingGatewayError, 'Order not specified' if order.nil?
        @store = order.store
        @group = user&.group(@store)
        @api_key = @store.unifaun_api_key.presence || TEST_KEY
        @secret = @store.unifaun_secret.presence || TEST_SECRET
        @locale = I18n.locale
        @shipment_api = ShippingGateway::Connector::Unifaun.new(@api_key, @secret)
        @location_api = ShippingGateway::Connector::PostiLocationService.new
      end

      def prepare_interface_data(params = {})
        {}
      end

      def calculated_cost(base_price, metadata)
        base_price
      end

      # Sends a shipment with given options that are merged into the default shipment options.
      def send_shipment(options)
        raise ShippingGatewayError, 'Shipment and user must be present' if shipment.nil? || user.nil?
        raise ShippingGatewayError, 'Shipping address must be present' unless @group.shipping_address.present?
        request = {pdfConfig: pdf_config, shipment: default_shipment.merge(options)}
        response = @shipment_api.create_shipment(request)
        result = response.parsed_response[0]
        raise ShippingGatewayError, result unless response.created? && result.present?
        status = result['id'].present?

        return [
          status,
          status && result['id'],
          status && result['parcels'][0]['parcelNo']
        ]
      end

      def fetch_label
        raise ShippingGatewayError, 'Shipment must be present' if shipment.nil?
        response = @shipment_api.get_shipping_label(shipment.number)
        result = response.parsed_response[0]
        raise ShippingGatewayError, 'Fetching shipping label failed' unless response.ok? && result.present?
        status = result['pdf'].present?

        return [
          status,
          status && Base64.decode64(result['pdf'])
        ]
      end

      private

      def pdf_config
        {
          target1Media: 'laser-a5',
          target1XOffset: 0,
          target1YOffset: 0,
          target2Media: 'laser-a4',
          target2XOffset: 0,
          target2YOffset: 0,
          target3Media: nil,
          target3XOffset: 0,
          target3YOffset: 0,
          target4Media: nil,
          target4XOffset: 0,
          target4YOffset: 0,
        }
      end

      def default_shipment
        {
          orderNo: order.number,
          senderReference: order.our_reference,
          receiverReference: order.your_reference,
          sender: {
            name: @group.shipping_address.company.presence || @group.shipping_address.name,
            address1: @group.shipping_address.address1,
            address2: @group.shipping_address.address2,
            zipcode: @group.shipping_address.postalcode,
            city: @group.shipping_address.city,
            country: @group.shipping_address.country_code,
            mobile: @group.shipping_address.phone,
          },
          receiver: {
            name: order.shipping_address.name,
            address1: order.shipping_address.address1,
            address2: order.shipping_address.address2,
            zipcode: order.shipping_address.postalcode,
            city: order.shipping_address.city,
            country: order.shipping_address.country_code,
            email: order.customer_email,
            mobile: order.shipping_address.phone,
          },
          senderPartners: [{
            id: 'POSTI',
            custNo: @store.posti_customer_number,
          }],
          parcels: [{
            copies: 1,
            packageCode: shipment.package_type,
            weight: shipment.mass / 1000.0,
            valuePerParcel: true,
          }],
        }
      end

      def label_request
      end
    end

    class SmartPost < Base
      def prepare_interface_data(params = {})
        postalcode = params[:postalcode] || order.shipping_address.postalcode
        locations = smartpost_lookup(postalcode)
        {
          postalcode: postalcode,
          locations: locations
        }
      end

      def self.requires_maps?
        true
      end

      def smartpost_lookup(postalcode)
        query = {
          types: 'SMARTPOST',
          locationZipCode: postalcode,
          top: 6
        }
        response = @location_api.lookup(query).parsed_response
        response['locations'] or raise ShippingGatewayError, response['message']
      end

      def send_shipment
        super({
          agent: {
            quickId: shipment.pickup_point_id
          },
          service: {
            id: 'PO2103'
          },
        })
      end

      def to_partial_path
        'shipping_gateway/smart_post'
      end
    end
  end
end
