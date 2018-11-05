Rails.application.configure do
  config.lograge.enabled = true

  config.lograge.custom_payload do |controller|
    {
      store: controller.current_store,
      user: controller.current_user.try(:id)
    }
  end
end
