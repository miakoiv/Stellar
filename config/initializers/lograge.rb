Rails.application.configure do
  config.lograge.enabled = true

  config.lograge.custom_payload do |controller|
    {
      store: controller.try(:current_store),
      user: controller.current_user.try(:id)
    }
  end
end
