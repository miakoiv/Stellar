module Admin::ActivitiesHelper

  def resource_name(activity)
    if activity.resource.present?
      "#{activity.resource_class.model_name.human} #{activity.resource}"
    else
      "#{t('admin.activities.deleted')} #{activity.resource_class.model_name.human}"
    end
  end

  def resource_link(activity)
    if activity.resource.present?
      link_to resource_name(activity), [:admin, activity.context]
    else
      resource_name(activity)
    end
  end
end
