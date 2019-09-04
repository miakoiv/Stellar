#
# Nav generation takes a store and a collection of records to
# create a dropdown page with the given name, populated with
# pages linking to the records.
#
class NavGenerationJob < ApplicationJob
  queue_as :default

  def perform(store, name, categories)
    dropdown = store.pages.create!(
      purpose: 'dropdown',
      title: name,
      live: true
    )
    dropdown.create_nav_menu!(categories)
  end
end
