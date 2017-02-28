class AddResourceToPages < ActiveRecord::Migration
  def change
    add_reference :pages, :resource, polymorphic: true, after: :purpose
  end
end
