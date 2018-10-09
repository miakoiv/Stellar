#encoding: utf-8

module PaymentGateway
  class PaymentMethod

    include ActiveModel::Model

    attr_accessor :group, :name, :slug, :min_cents, :max_cents, :image_url

    def valid_for?(cents)
      cents.between?(min_cents, max_cents)
    end
  end
end
